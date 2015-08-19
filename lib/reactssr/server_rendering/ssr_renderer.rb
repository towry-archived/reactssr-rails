
require 'multi_json'
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
        
        @manifest_base ||= File.join(::Rails.public_path, ::Rails.application.config.assets.prefix)
        load_asset_on_init

        super(options.merge(code: js_code))
      end

      def render(component_name, props, pre_options)
        prerender_options = pre_options[:prerender_options]

        @controller_path = pre_options.fetch(:controller_path, nil)
        # @action_name = pre_options.fetch(:action_name, nil)

        # if @controller_path.nil? or @action_name.nil?
        if @controller_path.nil?
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

        success = false
        if ::Rails.env.production?
          content, success = load_asset(entry)
        end

        if not success
          jscode << ::Rails.application.assets[entry].to_s
        else 
          jscode << content
        end

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
        entry = File.join(components, "#{@controller_path}.ssr.js")
      end

      private

      # Return asset content
      def load_asset(filename)
        digest_path = assets[filename]

        if digest_path.nil?
          return '', false 
        end

        file = File.join(@manifest_base, digest_path)
        if not File.exist?(file)
          return '', false 
        end

        return File.read(file), true
      end

      def assets
        @data['assets'] ||= {}
      end

      def files
        @data['files'] ||= {}
      end

      # load assets from Rails.public_path
      def load_asset_on_init
        paths = Dir[File.join(@manifest_base, "manifest*.json")]
        if paths.any?
          path = paths.first
        else 
          # No precompile
          return {}
        end

        begin
          if File.exist?(path)
            data = json_decode(File.read(path))
          end
        rescue ::MultiJson::DecodeError => e
          return {}
        end

        @data = data.is_a?(Hash) ? data : {}
      end

      if ::MultiJson.respond_to?(:dump)
        def json_decode(obj)
          ::MultiJson.load(obj)
        end
      else
        def json_decode(obj)
          ::MultiJson.decode(obj)
        end
      end
    end

    # Common error
    class RuntimeCommonError < RuntimeError
    end
  end
end
