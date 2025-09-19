# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.0.6
FROM ruby:${RUBY_VERSION}-slim AS base
WORKDIR /myapp

ENV RAILS_ENV=development \
  BUNDLE_PATH=/usr/local/bundle \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# ---------- build ----------
FROM base AS build

# ネイティブ拡張のビルドに必要なもの（←ココ超重要）
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential ruby-dev \
  default-libmysqlclient-dev \
  git pkg-config \
  nodejs npm \
  libvips \
  bash && \
  npm install -g yarn && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN gem install bundler -v 2.5.23

# 依存だけ先に入れてキャッシュを効かせる
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'production' && \
  bundle install && \
  rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

# アプリ本体
COPY . .

# ---------- runtime ----------
FROM base AS runtime

# 実行に最低限必要なもの（mysql2 ランタイムにクライアントライブラリ）
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  default-mysql-client \
  nodejs npm \
  libvips \
  bash && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN gem install bundler -v 2.5.23

# build で作った bundle をコピー
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . .

# 非 root
RUN useradd -m -s /bin/bash rails && \
  mkdir -p /myapp/log /myapp/tmp /myapp/storage && \
  chown -R rails:rails /myapp
USER rails:rails
WORKDIR /myapp

EXPOSE 3000
# Spring を避けるため bin/rails は使わず bundle exec を明示
CMD ["bash", "-lc", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0 -p 3000"]
