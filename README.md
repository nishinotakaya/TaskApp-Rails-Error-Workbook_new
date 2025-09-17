# サンプルアプリケーション

このアプリケーションを土台として、タスク管理機能を持つアプリへ拡張していただきます。

## 開発環境

- AWS Cloud9
- Ruby
- Git
- Heroku

```
$ git clone https://github.com/sample-874/sample-app.git
```

上記のコマンド実行（リポジトリをクローン）後、
次のコマンドで必要になる RubyGems をインストールします。

```
$ docker compose build web --no-cache
$ docker compose run --rm -u root web bundle install
```

その後、データベースへのマイグレーションを実行します。

```
$ docker compose exec web bin/rails db:migrate
```

マイグレーション実行後、サンプルユーザーを生成します。

```
$ docker compose exec web bin/rails db:seed
```

これで Rails サーバーを立ち上げる準備が整いました。

```
$ docker compose up -d

# コンテナを削除
$ docker compose down -v && docker compose up -d
```

ユーザーの新規作成やログインなどは既に出来る状態になっているはずです。

- **email** : sample@email.com
- **password** : password

反映されない場合

```
docker compose exec web bin/spring stop
docker compose exec web bin/rails tmp:clear
docker compose exec web rm -f tmp/pids/server.pid
```
