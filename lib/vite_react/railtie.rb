require "rails"
require "rails/railtie"
require "rails/generators"
require "rails/generators/rails/scaffold/scaffold_generator"


module ViteReact
  module ScaffoldGenerator
    extend ActiveSupport::Concern
    included do
      hook_for :scaffold, in: nil, default: true, type: :boolean
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
      Rails::Generators::ScaffoldGenerator.include ViteReact::ScaffoldGenerator
    end
  end
end
