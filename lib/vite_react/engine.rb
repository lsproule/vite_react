require "rails"

module ViteReact
  class Engine < ::Rails::Engine
    config.app_generators do |g|
      g.scaffold_controller :vite_react
    end
  end
end

