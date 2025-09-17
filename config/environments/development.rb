Rails.application.configure do
  # --- 基本 ---
  config.cache_classes = false
  config.eager_load    = false
  config.consider_all_requests_local = true
  config.hosts.clear   # Docker からのアクセスでホスト制限に引っかからないように

  # --- リロード系（コントローラも即反映させる要点） ---
  config.file_watcher = ActiveSupport::FileUpdateChecker
  config.reload_classes_only_on_change = false
  config.enable_reloading = true if config.respond_to?(:enable_reloading)

  # --- キャッシュ/ログ ---
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
  config.active_support.deprecation = :log
  config.assets.debug  = true
  config.assets.quiet  = true
  config.active_record.migration_error = :page_load

  # --- メール（お好みで）
  config.action_mailer.perform_caching = false
  if defined?(LetterOpenerWeb)
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true
  end

  # 余計な強制チェックや after_initialize フックは入れない
end
