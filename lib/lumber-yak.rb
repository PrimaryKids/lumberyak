
require 'active_support'
require 'rails/railtie'
require 'lograge'
require 'lograge/railtie'
require 'lograge/formatter/noformat'


module LumberYak
  module_function
  mattr_accessor :application

  def setup(app)
    self.application = app
    setup_logger
    setup_lograge
    setup_logtags
    enable_json_logging
  end

  class LumberYakRailtie < ::Rails::Railtie
    config.lumberyak = ActiveSupport::OrderedOptions.new
    config.lumberyak.enabled = false
    config.lumberyak.configure_lograge = true
    config.lumberyak.log_tags = nil

    config.after_initialize do |app|
      LumberYak.setup(app) if app.config.lumberyak.enabled
    end
  end


  def setup_logger
    new_logger = ActiveSupport::TaggedLogging.new(application.config.logger)
    application.config.logger = new_logger
    Rails.logger = new_logger
  end

  def setup_lograge
    if config.configure_lograge
      application.configure do |config|
        config.lograge.enabled = true
        config.lograge.formatter = Lograge::Formatters::NoFormat.new
      end
      Lograge.setup(application)
    end
  end

  def setup_logtags
    if config.log_tags
      application.config.log_tags = config.log_tags
    end
  end

  def enable_json_logging
    # Explicitly require our monkey patch to ensure it takes effect.
    require 'activesupport/taggedlogging/formatter.rb'
  end

  def config
    application.config.lumberyak
  end
end





