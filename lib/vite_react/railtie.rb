require "rails"
require "rails/railtie"
require "rails/generators"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

# Explicitly require your custom generator file
require_relative "../generators/vite_react/scaffold_controller/scaffold_controller_generator"

module ViteReact
  class Railtie < ::Rails::Railtie
    # Load the custom generator during Rails initialization
    generators do
      Rails::Generators.configure! Rails.application.config.generators
    end

    initializer "vite_react.add_generator_hooks" do
      # Prepend the custom scaffold generator logic
      Rails::Generators::ScaffoldControllerGenerator.prepend ViteReact::Generators::ScaffoldControllerGenerator
    end

    # Optionally load rake tasks
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
