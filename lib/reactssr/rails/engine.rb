module Reactssr
  module Rails
    class Engine < ::Rails::Engine 
      initializer 'reactssr.assets.precompile' do |app|
        app.config.assets.precompile += %w(
          components/*.ssr.js
        )
      end
    end
  end
end
