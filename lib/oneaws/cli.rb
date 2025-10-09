require 'thor'
require 'oneaws/client'
require 'inifile'

module Oneaws
  class Cli < Thor
    default_command :getkey

    desc 'getkey', 'getkey'
    option :update_aws_credentials, aliases: "-u", type: :boolean, default: true
    option :profile, aliases: "-p", type: :string, default: "oneaws"
    option :eval, type: :string, enum: ["bash", "fish"]
    option :otp, type: :string, default: ENV['ONEAWS_OTP_CODE']
    def getkey
      client = Client.new

      params = {
        username: ENV['ONELOGIN_USERNAME'],
        password: ENV['ONELOGIN_PASSWORD'],
        app_id: ENV['ONELOGIN_APP_ID'],
        subdomain: ENV['ONELOGIN_SUBDOMAIN'],
      }
      credential = client.issue_credential(params, options[:otp])

      if options["update_aws_credentials"]
        credential_file = File.expand_path(find_credentials)
        unless inifile = IniFile.load(credential_file)
          FileUtils.mkdir_p(File.dirname(credential_file))
          inifile = IniFile.new
        end

        profile = options["profile"]

        inifile[profile]["aws_access_key_id"] = credential.access_key_id
        inifile[profile]["aws_secret_access_key"] = credential.secret_access_key
        inifile[profile]["aws_session_token"] = credential.session_token
        inifile.write(filename: credential_file)
      end

      case options["eval"]
      when "bash"
        puts <<~EOS
        export AWS_ACCESS_KEY_ID='#{credential.access_key_id}'
        export AWS_SECRET_ACCESS_KEY='#{credential.secret_access_key}'
        export AWS_SESSION_TOKEN='#{credential.session_token}'
        EOS
      when 'fish'
        puts <<~EOS
        set -x AWS_ACCESS_KEY_ID '#{credential.access_key_id}'
        set -x AWS_SECRET_ACCESS_KEY '#{credential.secret_access_key}'
        set -x AWS_SESSION_TOKEN '#{credential.session_token}'
        EOS
      end
    end

    desc 'version', 'Show version'
    def version
      puts Oneaws::VERSION
    end

    private

    # AWS の credential を以下の順番で存在チェックをする
    # 1. ~/.aws/credentials
    # 2. ~/.config/aws/credentials
    # 存在しない場合は順番1つ目のものを用いる
    def find_credentials
      credentials = ["~/.aws/credentials", "~/.config/aws/credentials"]
      credential = credentials.find{|c| File.exist? File.expand_path(c) }
      if credential
        credential
      else
        credentials.first
      end
    end
  end
end
