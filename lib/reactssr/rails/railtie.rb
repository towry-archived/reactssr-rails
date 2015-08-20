module Reactssr
  module Rails
    class Railtie < ::Rails::Railtie
      GEM_ROOT = Pathname.new('../../../../').expand_path(__FILE__)

      config.reactssr = ActiveSupport::OrderedOptions.new 

      # The folder that contains all the stuff
      config.reactssr.assets_base = 'components'

      initializer "reactssr.setup_view_helpers", group: :all do |app|
        ActiveSupport.on_load(:action_view) do 
          include ::Reactssr::Rails::ViewHelper
        end
      end

      config.before_initialize do |app|
        app.config.react.server_renderer = ::Reactssr::ServerRendering::SsrRenderer

        our_asset_path = GEM_ROOT.join('lib/assets/').to_s
        app.config.assets.paths << our_asset_path
      end
    end
  end
end
