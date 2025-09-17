# syntax = docker/dockerfile:1

# Ruby 3.0.6 をベースにする
ARG RUBY_VERSION=3.0.6
FROM ruby:${RUBY_VERSION}-slim AS base

# Rails app lives here
WORKDIR /myapp

# 共通環境変数
ENV RAILS_ENV="development" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_JOBS="4" \
  BUNDLE_RETRY="3"

# --------------------------
# Build stage（ネイティブ拡張のビルド用）
# --------------------------
FROM base AS build

# ビルドに必要なパッケージ（Cコンパイラ、ヘッダ、DBクライアント、Node/Yarnなど）
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  ruby-dev \
  libgmp-dev \
  default-libmysqlclient-dev \
  libpq-dev \
  git \
  libvips \
  pkg-config \
  nodejs \
  npm \
  bash \
  gcc \
  g++ \
  make && \
  npm install -g yarn && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Bundler を固定
RUN gem install bundler -v 2.5.23

# 依存だけ先にコピーして bundle install のキャッシュを効かせる
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache \
  "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# アプリ本体をコピー
COPY . .

# --------------------------
# Runtime stage（実行用・軽量）
# --------------------------
FROM base AS runtime

# 実行時に最低限必要なパッケージ（＋ネイティブ拡張用にdev系も入れる）
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  ruby-dev \
  libgmp-dev \
  default-libmysqlclient-dev \
  libpq-dev \
  git \
  libvips \
  pkg-config \
  nodejs \
  npm \
  bash \
  gcc \
  g++ \
  make && \
  npm install -g yarn && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Bundler は runtime 側にも入れておく
RUN gem install bundler -v 2.5.23

# build で作った gem とアプリ本体をコピー
COPY --from=build /usr/local/bundle /usr/local/bundle

# 非rootユーザー
RUN useradd rails --create-home --shell /bin/bash && \
  mkdir -p /myapp/db /myapp/log /myapp/storage /myapp/tmp && \
  chown -R rails:rails /myapp

USER rails:rails
WORKDIR /myapp

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
