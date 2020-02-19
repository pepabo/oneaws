require 'onelogin'
require 'aws-sdk-core'

module Oneaws
  class Client
    class SamlRequestError < StandardError; end

    def initialize
      @onelogin = OneLogin::Api::Client.new({
        client_id: ENV['ONELOGIN_CLIENT_ID'],
        client_secret: ENV['ONELOGIN_CLIENT_SECRET'],
        region: ENV['ONELOGIN_REGION'] || 'us',
      })

      @aws = Aws::STS::Client.new(
        credentials: Aws::AssumeRoleCredentials,
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

      # sent push notification to OneLogin Protect
      response = @onelogin.get_saml_assertion_verifying(app_id, mfa.devices[0].id, mfa.state_token, nil, nil, false)
      if response.nil?
        raise SamlRequestError.new("#{@onelogin.error} #{@onelogin.error_description}")
      end

      while response.type != "success" do
        sleep 1
        response = @onelogin.get_saml_assertion_verifying(app_id, mfa.devices[0].id, mfa.state_token, nil, nil, true)
        if response.nil?
          raise SamlRequestError.new("#{@onelogin.error} #{@onelogin.error_description}")
        end
      end

      saml_assertion = response.saml_response

      params = {
        duration_seconds: 3600,
        principal_arn: ENV['AWS_PRINCIPAL_ARN'],
        role_arn: ENV['AWS_ROLE_ARN'],
        saml_assertion: saml_assertion,
      }
      @aws.assume_role_with_saml(params)[:credentials]
    end
  end
end
