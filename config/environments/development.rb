Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.hosts.clear

  config.file_watcher = ActiveSupport::FileUpdateChecker

  # ★ Rails標準の挙動に戻す（変更があった時だけ再読み込み）
  config.reload_classes_only_on_change = true


  config.action_controller.perform_caching = false
  config.cache_store = :null_store
  config.active_support.deprecation = :log
  config.assets.debug = true
  config.assets.quiet = true
  config.active_record.migration_error = :page_load
end
