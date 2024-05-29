require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dfgrb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_mailer.smtp_settings = {
      address: "mail.uni-mainz.de",
      port: 587,
      user_name: "kkevin",
      password: "A1n#2u,bis12",
      authentication: "login",
      enable_starttls: true,
      open_timeout: 5,
      read_timeout: 5
    }
  end
end

# pyfrom 'scipy.cluster.hierarchy', import: [:dendrogram, :linkage]
