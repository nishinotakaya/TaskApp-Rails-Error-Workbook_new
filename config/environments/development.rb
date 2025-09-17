Rails.application.configure do
  # --- 基本 ---
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  # --- キャッシュ ---
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

  # --- メール ---
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.perform_deliveries = true

  # --- デバッグ ---
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.quiet = true

  # --- Docker環境向け ---
  # ファイル変更を必ず反映
  config.file_watcher = ActiveSupport::FileUpdateChecker


  config.after_initialize do
    Rails.application.reloader.check!
  end
end
