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
export DURATION_SECONDS=<token duration(sec)> # Option: default 3600

# fish
set -x ONELOGIN_CLIENT_ID <your onelogin client id>
set -x ONELOGIN_CLIENT_SECRET <your onelogin client secret>
set -x ONELOGIN_USERNAME <your onelogin username>
set -x ONELOGIN_PASSWORD <your onelogin password>
set -x ONELOGIN_APP_ID <your onelogin app_id>
set -x ONELOGIN_SUBDOMAIN <your onelogin subdomain>
set -x AWS_ROLE_ARN <your aws role arn>
set -x AWS_PRINCIPAL_ARN <your aws idp arn>
set -x DURATION_SECONDS <token duration(sec)> # Option: default 3600
```

環境変数を設定したら実行します。

```
oneaws
```

`-u` オプションをつけていると `~/.aws/credentials` に追記されます(default: true)。

### ONEAWS_MFA_DEVICE

MFA デバイスを複数登録している場合、以下のようにデバイスの選択を求められます。

```
Available MFA devices:
1. OneLogin Protect (ID: ***)
2. OneLogin Auth (ID: ***)

Select MFA device (1-2):
```

デバイスの選択が面倒な場合は、環境変数 `ONEAWS_MFA_DEVICE` を指定することで、指定した番号のデバイスを自動で選択できます。上記を例にすると、`1. OneLogin Protect` を選ぶ場合は `ONEAWS_MFA_DEVICE=1` と指定します。

ワンタイムパスワードが必要なデバイスを選択した場合、 `--otp` オプションでワンタイムパスワードを指定することができます。
