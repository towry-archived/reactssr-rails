
require 'react-rails'

module Reactssr
  module ServerRendering
    class SsrRenderer < ::React::ServerRendering::ExecJSRenderer
      def initialize(options = {})
        @replay_console = options.fetch(:replay_console, true)
        filenames = options.fetch(:files, ['react.js'])

        js_code = CONSOLE_POLYFILL.dup 

        filenames.each do |filename|
          js_code << ::Rails.application.assets[filename].to_s
        end

        @before_render_code ||= File.read("#{File.dirname __FILE__}/../assets/before_render.js")

        super(options.merge(code: js_code))
      end

      def render(component_name, props, pre_options)
        prerender_options = pre_options[:prerender_options]

        @controller_path = pre_options.fetch(:controller_path, nil)
        @action_name = pre_options.fetch(:action_name, nil)

        if @controller_path.nil? or @action_name.nil?
          raise Reactssr::ServerRendering::RuntimeCommonError.new("Could not found the controller path or action name in current context.")
        end

        # pass prerender: :static to use renderToStaticMarkup
        react_render_method = if prerender_options == :static
            "renderToStaticMarkup"
          else
            "renderToString"
          end

        if !props.is_a?(String)
          props = props.to_json
        end

        our_component_name = "Components.#{component_name}"

        super(our_component_name, props, {render_function: react_render_method})
      end

      # This will insert some js code before the
      # React.render
      # So, we will gather all the code for that controller#action
      # in here.
      def before_render(component_name, props, prerender_options)
        jscode = @before_render_code.dup 
        jscode << ::Rails.application.assets[entry].to_s

        # the result is jscode
        jscode
      end

      def after_render(component_name, props, prerender_options)
        @replay_console ? CONSOLE_REPLAY : ""
      end

      # @see `react/server_rendring/sprockets_rendering.rb`
      CONSOLE_POLYFILL = <<-JS
        var console = { history: [] };
        ['error', 'log', 'info', 'warn'].forEach(function (fn) {
          console[fn] = function () {
            console.history.push({level: fn, arguments: Array.prototype.slice.call(arguments)});
          };
        });
      JS

      # @see `react/server_rendring/sprockets_rendering.rb`
      CONSOLE_REPLAY = <<-JS
        (function (history) {
          if (history && history.length > 0) {
            result += '\\n<scr'+'ipt>';
            history.forEach(function (msg) {
              result += '\\nconsole.' + msg.level + '.apply(console, ' + JSON.stringify(msg.arguments) + ');';
            });
            result += '\\n</scr'+'ipt>';
          }
        })(console.history);
      JS

      protected

      def entry
        components = ::Rails.application.config.reactssr.assets_base || 'components'
        entry_file = ::Rails.application.config.reactssr.entry || 'index.ssr.js'
        sub_path = File.join(@controller_path, @action_name)
        entry = File.join(components, sub_path, 'index.ssr.js')
      end
    end

    # Common error
    class RuntimeCommonError < RuntimeError
    end
  end
end
