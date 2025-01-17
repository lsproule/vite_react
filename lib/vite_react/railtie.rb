require "rails"
require "rails/railtie"
require "rails/generators"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"


module ViteReact
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/install.rake"
    end

    puts Rails::Generators.lookup(["vite_react:scaffold_controller"])

    config.app_generators do |g| 
      g.scaffold_controller :vite_react
    end
  end
end
