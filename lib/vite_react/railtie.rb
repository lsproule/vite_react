require "rails"

module ViteReact
  class Railtie < ::Rails::Railtie
        rake_tasks do
          load "tasks/install.rake"
        end
  end
end
