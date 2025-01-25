module ViteReact
  module Generators
    class DeviseGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      def add_devise_to_gemfile
        gem "devise"
        gem "devise-jwt"
      end

      def install_devise
        generate "devise:install"
      end
    end
  end
end
