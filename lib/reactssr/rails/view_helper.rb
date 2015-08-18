
require 'react-rails'

module Reactssr
  module Rails
    module ViewHelper
      # @see `React::Rails::ViewHelper react_component`
      def react_ssr(name, props = {}, options = {}, &block)
        options = {:tag => options} if options.is_a?(Symbol)

        prerender_options = options[:prerender]
        if !prerender_options and Rails.application.config.react.server_renderer != ::Reactssr::ServerRendering::SsrRenderer
          return react_component(name, props, options, &block)
        end

        # All the below stuff is to send the `controller_name`
        # and `action_name` to our ssr_renderer.
        # I am not too familiar with ruby, so if there is a better
        # way, please contribute!
        
        # Let reactssr-rails handle that.
        pre_options = {
          prerender_options: prerender_options,
          controller_path: controller_path,
          action_name: action_name
        }

        block = Proc.new { concat ::React::ServerRendering.render(name, props, pre_options) }
        
        html_options = options.reverse_merge(:data => {})
        html_options[:data].tap do |data|
          data[:react_props] = (props.is_a?(String) ? props : props.to_json)
        end
        html_tag = html_options[:tag] || :div

        # remove internally used properties so they aren't rendered to DOM
        html_options.except!(:tag, :prerender)

        content_tag(html_tag, '', html_options, &block)
      end
    end
  end
end
