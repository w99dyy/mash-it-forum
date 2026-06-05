require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # --- SSL / PROXY SETTINGS ---
  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  # ----------------------------

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :primary } }  # default queue

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = {
    host: 'mashiverse.com',
    protocol: 'https'
  }
  config.action_mailer.delivery_method = :resend
  config.action_mailer.resend_settings = {
    api_key: ENV["RESEND_API_KEY"]
  }

  # Enable locale fallbacks for I18n.
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # DNS rebinding protection.
  # Note: Since you are using a custom domain, you should uncomment this
  # and add your domain if you still see "Blocked host" errors.
  # Add all possible hosts that might connect to the app
  config.hosts = [
    "mashiverse.com",
    "www.mashiverse.com", 
    "212.227.161.11",
    /.*\.kamal\.local$/,
    /.*\.internal$/,
    /[a-f0-9]+/,           # Matches container ID
    /[a-f0-9]+:\d+/,       # Matches container ID with port (like 1408e684efc6:3001)
    /.*\.ionos\.local$/
  ]

  config.action_controller.default_url_options = { host: 'mashiverse.com', protocol: 'https' }
  config.action_mailer.default_url_options = { host: 'mashiverse.com', protocol: 'https' }
end
