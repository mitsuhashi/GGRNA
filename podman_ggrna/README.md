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

`apache/000-default.conf` では、Apache の MultiViews が `index.cgi.en` / `index.cgi.ja` を選択する前に、クエリパラメータ付きURLを正規URLへリダイレクトします。リバースプロキシが `X-Forwarded-Proto: https` を付与する場合は、リダイレクト先も `https://` になります。

正規化リダイレクトの確認:

```sh
curl -I http://localhost:30082/ja/?lang=en
curl -I http://localhost:30082/?spe=hs
curl -I 'http://localhost:30082/ja/caagaagagattg?lang=en&spe=mm&format=txt'
curl -I http://localhost:30082/en/mm/caagaagagattg.txt
curl -I -H 'X-Forwarded-Proto: https' \
  'http://localhost:30082/ja/caagaagagattg?lang=en&spe=mm&format=txt'
```

期待される結果:

```text
/ja/?lang=en -> /en/
/?spe=hs -> /hs/
/ja/caagaagagattg?lang=en&spe=mm&format=txt -> /en/mm/caagaagagattg.txt
/en/mm/caagaagagattg.txt -> 200 OK, text/plain
```

Apache設定の構文確認:

```sh
podman exec podman_ggrna_web_1 apache2ctl configtest
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
