require "rails"

module ViteReact
  class Railtie < ::Rails::Railtie
        rake_tasks do
          load "tasks/vite_react.rake"
        end
  end
end
