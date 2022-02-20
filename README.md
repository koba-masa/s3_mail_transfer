# transfer_s3_mail
AWS SESにてS3に格納されたメールをLambdaで転送する

## 環境変数
|キー|概要|備考|
|:--|:--|:--|
|BUCKET_NAME|SESが受信したメールを保存するバケット名||
|OBJECT_PREFIX|SESが受信したメールを保存するバケットのプレフィックス名||
|S3_REGION|SESが受信したメールを保存するバケットのリージョン||
|DEVELOPER_TO|開発者宛メールアドレス|カンマ区切りの複数指定可|
|FORWARD_TO|転送先メールアドレス|カンマ区切りの複数指定可|
|TRANSFER_FROM|転送元メールアドレス||
|DEBUG_MODE|ログレベル|`0`: デバッグON/`1`: デバッグOFF|
