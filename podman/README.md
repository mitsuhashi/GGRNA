Podman ローカル起動
==================

このディレクトリには、GGRNA を Podman と Apache でローカル起動するためのファイルが含まれています。

APACHE_PORT を `.env` で指定します。

```sh
cat .env
APACHE_PORT=30082
```

起動:

```sh
podman-compose up -d --build
```

確認:

```sh
curl -I http://localhost:30082
curl http://localhost:30082 | head
curl -I http://localhost:30082/help.html
curl -I http://localhost:30082/en/advanced.html
```

停止:

```sh
podman-compose down
```

ログ確認:

```sh
podman-compose logs web
```

ユーザーサービスとして登録:

```sh
./podman_enable_service.sh podman-compose-ggrna
```

上記を実行すると `~/.config/systemd/user/podman-compose-ggrna.service` が作成され、`podman-compose.yml` のサービスが現在のユーザーの systemd サービスとして有効化・起動されます。

OS 再起動後にログイン前から起動できるよう、スクリプトは `loginctl enable-linger $USER` を可能な場合に実行します。権限不足などで有効化できない場合は警告が表示されるため、必要に応じて同じコマンドを一度実行してください。生成される systemd サービスには Podman 起動可能状態の事前確認と失敗時の自動再試行が含まれます。

状態確認:

```sh
systemctl --user status podman-compose-ggrna
```

自動起動の無効化と停止:

```sh
./podman_disable_service.sh podman-compose-ggrna
```
