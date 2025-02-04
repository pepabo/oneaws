require 'onelogin'
require 'aws-sdk-core'
require 'io/console'

module Oneaws
  class Client
    class SamlRequestError < StandardError; end
    class MfaDeviceNotFoundError < StandardError; end;

    def initialize
      @onelogin = OneLogin::Api::Client.new({
        client_id: ENV['ONELOGIN_CLIENT_ID'],
        client_secret: ENV['ONELOGIN_CLIENT_SECRET'],
        region: ENV['ONELOGIN_REGION'] || 'us',
      })

      @aws = Aws::STS::Client.new(
        credentials: nil,
        region: ENV['AWS_REGION'] || 'ap-northeast-1',
      )
    end

    def issue_credential(options)
      username = options[:username]
      password = options[:password]
      app_id = options[:app_id]
      subdomain = options[:subdomain]
      response = @onelogin.get_saml_assertion(username, password, app_id, subdomain)
      if response.nil?
        raise SamlRequestError.new("#{@onelogin.error} #{@onelogin.error_description}")
      end

      mfa = response.mfa
      mfa_device = select_mfa_device(mfa)
      
      device_types_that_do_not_require_token = [
        "OneLogin Protect"
      ]

      otp_token = unless device_types_that_do_not_require_token.include?(mfa_device.type)
        print "input OTP of #{mfa_device.type}: "
        STDIN.noecho(&:gets)
      end

      response = @onelogin.get_saml_assertion_verifying(app_id, mfa_device.id, mfa.state_token, otp_token, nil, false)
      
      if response.nil?
        raise SamlRequestError.new("#{@onelogin.error} #{@onelogin.error_description}")
      end

      while response.type != "success" do
        sleep 1
        response = @onelogin.get_saml_assertion_verifying(app_id, mfa_device.id, mfa.state_token, nil, nil, true)
        if response.nil?
          raise SamlRequestError.new("#{@onelogin.error} #{@onelogin.error_description}")
        end
      end

      saml_assertion = response.saml_response

      params = {
        duration_seconds: (ENV['DURATION_SECONDS'] || 3600).to_i,
        principal_arn: ENV['AWS_PRINCIPAL_ARN'],
        role_arn: ENV['AWS_ROLE_ARN'],
        saml_assertion: saml_assertion,
      }
      @aws.assume_role_with_saml(params)[:credentials]
    end

    private

    def select_mfa_device(mfa)
      if mfa.devices.length == 1
        return mfa.devices.first
      end

      if selection = ENV["ONEAWS_MFA_DEVICE"] &.to_i
        if selection <= 0
          warn "ONEAWS_MFA_DEVICE must be >= 1"
          exit 1
        end

        return mfa.devices[selection - 1]
      end

      puts "\nAvailable MFA devices:"
      mfa.devices.each_with_index do |device, index|
        puts "#{index + 1}. #{device.type} (ID: #{device.id})"
      end

      print "\nSelect MFA device (1-#{mfa.devices.length}): "
      selection = STDIN.gets.chomp.to_i

      if selection < 1 || selection > mfa.devices.length
        raise MfaDeviceNotFoundError.new("Invalid device selection.")
      end

      mfa.devices[selection - 1]
    end
  end
end
