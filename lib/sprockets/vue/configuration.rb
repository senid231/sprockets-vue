module Sprockets::Vue
  class Configuration

    attr_accessor :js_variable_name, :babel_options, :coffee_options

    def initialize
      # assign defaults
      @js_variable_name = 'VCompents'
      @babel_options = {}
      @coffee_options = {}
    end

  end
end
