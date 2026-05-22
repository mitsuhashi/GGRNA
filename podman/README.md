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

状態確認:

```sh
systemctl --user status podman-compose-ggrna
```

自動起動の無効化と停止:

```sh
./podman_disable_service.sh podman-compose-ggrna
```
