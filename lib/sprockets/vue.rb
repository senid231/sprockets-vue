require 'sprockets'
require 'sprockets/vue/version'
require 'sprockets/vue/utils'
require 'sprockets/vue/script'
require 'sprockets/vue/style'
require 'sprockets/vue/configure'
module Sprockets

  def self.configure
    yield(Configure) if block_given?
  end

  if respond_to?(:register_transformer)
    register_mime_type 'text/vue', extensions: ['.vue'], charset: :unicode
    register_transformer 'text/vue', 'application/javascript', Vue::Script
    register_transformer 'text/vue', 'text/css', Vue::Style

    register_processor 'text/vue', Sprockets::DirectiveProcessor
  end
end
