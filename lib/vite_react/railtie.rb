require "rails"
require "rails/railtie"
require "rails/generators"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"


module ViteReact
  module ScaffoldControllerGenerator
    extend ActiveSupport::Concern
    included do
      hook_for :scaffold_controller, in: nil, default: true, type: :boolean
    end
  end
end



module ViteReact
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/install.rake"
    end
    generators do |app|
      Rails::Generators.configure! app.config.generators
      Rails::Generators::ScaffoldControllerGenerator.include ViteReact::ScaffoldControllerGenerator
    end
  end
end
