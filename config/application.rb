require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyBoke
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # 应用统一使用东八区北京时间；数据库时间仍以 UTC 保存，读取时由 Rails 自动转换。
    config.time_zone = "Beijing"
    config.active_record.default_timezone = :utc
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.default_locale = :"zh-CN"
    config.i18n.available_locales = [:"zh-CN", :en]
  end
end
