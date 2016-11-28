require 'active_support/concern'
require 'action_view'
module Sprockets::Vue
  class Script
    class << self
      include ActionView::Helpers::JavaScriptHelper

      SCRIPT_REGEX = Utils.node_regex('script')
      TEMPLATE_REGEX = Utils.node_regex('template')
      SCRIPT_COMPILES = {
          'coffee' => ->(s, input) {
            CoffeeScript.compile s, coffee_options(input)
          },
          'es6' => ->(s, input) {
            Babel::Transpiler.transform s, babel_options(input)
          },
          nil => ->(s, _input) { {'js' => s} }
      }

      def call(input)
        data = input[:data]
        name = input[:name]
        input[:cache].fetch([cache_key, input[:filename], data]) do
          script = SCRIPT_REGEX.match(data)
          template = TEMPLATE_REGEX.match(data)
          var_name = Configure.js_variable_name
          output = []
          map = nil
          if script
            result = SCRIPT_COMPILES[script[:lang]].call(script[:content], input)
            map = result['sourceMap']

            code = result['js'] || result['code']
            output << "'object' != typeof #{var_name} && (#{var_name} = {});"
            output << "#{code}; VCompents['#{name}'] = vm;"
          end

          if template
            output << "#{var_name}['#{name.sub(/\.tpl$/, '')}'].template = '#{j template[:content]}';"
          end

          {data: "#{warp(output.join)}", map: map}
        end
      end

      def warp(s)
        "(function(){#{s}}).call(this);"
      end

      def cache_key
        [
            self.name,
            VERSION,
        ].freeze
      end

      def coffee_options(input)
        {sourceMap: true, sourceFiles: [input[:filename]], no_wrap: true}
      end

      def babel_options(input)
        opts = {
            'sourceRoot' => input[:load_path],
            'moduleRoot' => nil,
            'filename' => input[:filename],
            'filenameRelative' => input[:environment].split_subpath(input[:load_path], input[:filename])
        }

        if opts['moduleIds'] && opts['moduleRoot']
          opts['moduleId'] ||= File.join(opts['moduleRoot'], input[:name])
        elsif opts['moduleIds']
          opts['moduleId'] ||= input[:name]
        end

        opts
      end

    end
  end
end
