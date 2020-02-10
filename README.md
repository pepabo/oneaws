# oneaws

OneLoginとAWS STSを使って、一時的なセキュリティ情報を取得します。

## Usage

事前に環境変数を設定します。

```
# bash
export ONELOGIN_CLIENT_ID=<your onelogin client id>
export ONELOGIN_CLIENT_SECRET=<your onelogin client secret>
export ONELOGIN_USERNAME=<your onelogin username>
export ONELOGIN_PASSWORD=<your onelogin password>
export ONELOGIN_APP_ID=<your onelogin app_id>
export ONELOGIN_SUBDOMAIN=<your onelogin subdomain>
export AWS_ROLE_ARN=<your aws role arn>
export AWS_PRINCIPAL_ARN=<your aws idp arn>

# fish
set -x ONELOGIN_CLIENT_ID <your onelogin client id>
set -x ONELOGIN_CLIENT_SECRET <your onelogin client secret>
set -x ONELOGIN_USERNAME <your onelogin username>
set -x ONELOGIN_PASSWORD <your onelogin password>
set -x ONELOGIN_APP_ID <your onelogin app_id>
set -x ONELOGIN_SUBDOMAIN <your onelogin subdomain>
set -x AWS_ROLE_ARN <your aws role arn>
set -x AWS_PRINCIPAL_ARN <your aws idp arn>
```

環境変数を設定したら実行します。

```
oneaws
```

`-u` オプションをつけていると `~/.aws/credentials` に追記されます(default: true)。