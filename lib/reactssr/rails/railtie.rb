module Reactssr
  module Rails
    class Railtie < ::Rails::Railtie
      config.reactssr = ActiveSupport::OrderedOptions.new 

      # The folder that contains all the stuff
      config.reactssr.assets_base = 'components'

      # entry js file
      config.reactssr.entry = 'index.ssr.js'

      initializer "react_rails_ssr.setup_view_helpers", group: :all do |app|
        ActiveSupport.on_load(:action_view) do 
          include ::Reactssr::Rails::ViewHelper
        end
      end

      config.before_initialize do |app|
        app.config.react.server_renderer = ::Reactssr::ServerRendering::SsrRenderer
      end
    end
  end
end
