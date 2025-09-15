# syntax = docker/dockerfile:1

# Ruby 3.0.6
ARG RUBY_VERSION=3.0.6
FROM ruby:${RUBY_VERSION}-slim AS base

# Rails app lives here
WORKDIR /myapp

# 共通環境
ENV RAILS_ENV="development" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_JOBS="4" \
  BUNDLE_RETRY="3"

# --------------------------
# Build stage（ネイティブ拡張のビルド用）
# --------------------------
FROM base AS build

# 必要パッケージ（gem ビルド系 / MySQL / Node / Yarn）
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  default-libmysqlclient-dev \
  git \
  libvips \
  pkg-config \
  nodejs \
  npm \
  bash && \
  npm install -g yarn && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Bundler を固定（Gemfile.lock の 2.x 系想定。必要に応じて合わせてOK）
RUN gem install bundler -v 2.5.23

# 依存だけ先にコピーして bundle install のキャッシュを効かせる
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# アプリ本体をコピー
COPY . .


RUN bundle exec bootsnap precompile app/ lib/ || true

# （開発なので assets:precompile は不要。必要なら明示的に有効化）
# RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=development bundle exec rails assets:precompile


# --------------------------
# Runtime stage（実行用・軽量）
# --------------------------
FROM base AS runtime

# 実行時に必要な最低限のパッケージのみ
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  curl \
  default-mysql-client \
  libvips \
  bash && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Bundler は runtime 側にも入れておく（bundle exec 用）
RUN gem install bundler -v 2.5.23

# build で作った gem とアプリ本体をコピー
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /myapp /myapp

# 非rootユーザー
RUN useradd rails --create-home --shell /bin/bash && \
  mkdir -p /myapp/db /myapp/log /myapp/storage /myapp/tmp && \
  chown -R rails:rails /myapp

COPY bin/docker-entrypoint.sh /usr/local/bin/rails-entrypoint
RUN chmod 755 /usr/local/bin/rails-entrypoint

USER rails:rails
WORKDIR /myapp

ENTRYPOINT ["/usr/local/bin/rails-entrypoint"]

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
