# サンプルアプリケーション（Docker 版手順）

このアプリケーションを土台として、タスク管理機能を持つアプリへ拡張していただきます。  
※ 以下では Docker Compose のサービス名を **web** と想定しています（`docker-compose.yml` のサービス名が異なる場合は置き換えてください）。

## 開発環境

- Docker / Docker Compose
- Ruby（コンテナ内）
- Git
- （任意）Heroku

## セットアップ

### 1) リポジトリ取得 & ビルド

```bash
$ git clone https://github.com/sample-874/sample-app.git
$ cd sample-app
$ docker-compose build
```

### 2) DB 作成 & マイグレーション

Rails 6/7 なら `db:prepare`（作成＋マイグレーション）一発で OK。

```bash
$ docker-compose run --rm web bin/rails db:prepare
# （分けて実行する場合）
# $ docker-compose run --rm web bin/rails db:create
# $ docker-compose run --rm web bin/rails db:migrate
```

### 3) サンプルデータ投入（Seed）

```bash
$ docker-compose run --rm web bin/rails db:seed
```

### 4) サーバー起動

```bash
# フォアグラウンド
$ docker-compose up web

# バックグラウンド
$ docker-compose up -d web
```

アクセス: **http://localhost:3093**

## ログイン用テストユーザー

- **email** : `sample@email.com`
- **password** : `password`

## よく使う Docker 経由コマンド

```bash
# Railsコンソール
$ docker-compose exec web bin/rails console

# ルーティング確認
$ docker-compose exec web bin/rails routes

# ログ確認（フォロー）
$ docker-compose logs -f web

# 停止／片付け
$ docker-compose down
```

> Apple Silicon で DB イメージ非対応エラーが出る場合は、必要に応じて対象サービスに  
> `platform: linux/amd64` を指定することを検討してください。
