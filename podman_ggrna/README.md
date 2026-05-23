Podman ローカル起動
==================

このディレクトリには、GGRNA を Podman と Apache でローカル起動するためのファイルが含まれています。

nig-podman の方針に合わせ、Compose 定義は Docker/Podman 共通の `compose.yml` に置きます。Podman では対象ディレクトリで `podman-compose up` を実行します。

別ホストのリバースプロキシから接続できるよう、公開ポートは全インターフェースで待ち受けます。

この構成では Podman 固有の override は不要なため、`compose.override.podman.yml` は用意していません。将来 `userns_mode: "keep-id"` や Podman 固有の volume オプションが必要になった場合のみ追加します。

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

サーバー再起動後の自動起動:

```sh
systemctl --user enable podman-restart.service
```

`compose.yml` では `restart: always` を指定しているため、`podman-restart.service` が有効な環境ではサーバー再起動後に自動起動の対象になります。

確認:

```sh
systemctl --user is-enabled podman-restart.service
podman inspect --format '{{.HostConfig.RestartPolicy.Name}}' podman_ggrna_web_1
```
