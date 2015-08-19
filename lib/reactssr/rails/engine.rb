module Reactssr
  module Rails
    class Engine < ::Rails::Engine 
      initializer 'reactssr.assets.precompile' do |app|
        base = app.config.reactssr.assets_base
        precompile = File.join(base, '*.ssr.js')
        app.config.assets.precompile += [precompile]
      end
    end
  end
end
