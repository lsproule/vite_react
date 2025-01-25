module ViteReact
  module Generators
    class StripeGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      def add_devise_to_gemfile
        gem "stripe"
      end
    end
  end
end
