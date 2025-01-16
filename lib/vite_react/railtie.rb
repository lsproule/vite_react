require "rails"
require "rails/railtie"
require "rails/generators"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

module ViteReact
  class Railtie < ::Rails::Railtie
    # Ensure the custom generator is loaded
    generators do
      Rails::Generators.configure! Rails.application.config.generators
      require_relative "../generators/vite_react/scaffold_controller_generator/scaffold_controller_generator"
    end

    # Hook to extend the scaffold_controller behavior
    initializer "vite_react.add_generator_hooks" do
      Rails::Generators::ScaffoldControllerGenerator.prepend ViteReact::Generators::ScaffoldControllerGenerator
    end

    rake_tasks do
      load "tasks/install.rake" 
    end
  end
end


#require "rails"
#require "rails/railtie"
#require "rails/generators"
#require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"
#
#
#module ViteReact
#  module ScaffoldControllerGenerator
#    extend ActiveSupport::Concern
#    included do
#      hook_for :scaffold_controller, in: nil, default: true, type: :boolean
#    end
#  end
#end
#
#
#
#module ViteReact
#  class Railtie < ::Rails::Railtie
#    rake_tasks do
#      load "tasks/install.rake"
#    end
#    generators do |app|
#      Rails::Generators.configure! app.config.generators
#      Rails::Generators::ScaffoldControllerGenerator.include ViteReact::ScaffoldContollerGenerator
#    end
#  end
#end
