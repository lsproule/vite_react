require "rails"
require "rails/railtie"
require_relative "react_helper"



module ViteReact
  class Railtie < ::Rails::Railtie
    initializer "vite_react.action_view" do
      ActiveSupport.on_load(:action_view) do
        include ViteReact::ReactComponentHelper
      end
    end
    rake_tasks do
      load "tasks/install.rake"
    end
  end
end
