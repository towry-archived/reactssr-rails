
require 'react-rails'

module Reactssr
  module Rails
    module ViewHelper
      # @see `React::Rails::ViewHelper react_component`
      def react_ssr(name, props = {}, options = {}, &block)
        options = {:tag => options} if options.is_a?(Symbol)

        prerender_options = options.fetch(:prerender, true)

        prerender_options = true if prerender_options == false

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
        options.merge!(pre_options)

        block = Proc.new { concat ::React::ServerRendering.render(name, props, options) }
        
        html_options = options.reverse_merge(:data => {})
        html_options[:data].tap do |data|
          data[:react_props] = (props.is_a?(String) ? props : props.to_json)
        end
        html_tag = html_options[:tag] || :div

        # remove internally used properties so they aren't rendered to DOM
        html_options.except!(:tag, :rerender, :prerender_options, :controller_path, :action_name)

        output = content_tag(html_tag, '', html_options, &block)

        if options.fetch(:rerender, false)
          output << content_tag(:script, '', :data => {:reactssr_class => name.to_s})
        end

        output
      end
    end
  end
end
