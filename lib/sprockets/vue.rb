require 'sprockets'
require 'sprockets/vue/version'
require 'sprockets/vue/utils'
require 'sprockets/vue/script'
require 'sprockets/vue/style'
require 'sprockets/vue/configuration'
module Sprockets

  module Vue
    class << self
      attr_writer :configuration
    end

    # allow to configure Sprockets::Vue
    #
    #   Sprockets::Vue.configure do |config|
    #     config.js_variable_name = 'Qwe'
    #   end
    #
    def self.configure
      yield configuration if block_given?
    end

    def self.configuration
      @configuration ||= Sprockets::Vue::Configuration.new
    end
  end

  if respond_to?(:register_transformer)
    register_mime_type 'text/vue', extensions: ['.vue'], charset: :unicode
    register_transformer 'text/vue', 'application/javascript', Vue::Script
    register_transformer 'text/vue', 'text/css', Vue::Style

    register_processor 'text/vue', Sprockets::DirectiveProcessor
  end
end
