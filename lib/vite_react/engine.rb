require "rails"

module ViteReact
  class Engine < ::Rails::Engine
    config.app_generators do |generate|
       generate.assets true # create assets when generating a scaffold
       generate.force_plural false # allow pluralized model names
       generate.helper true # generate helpers
       generate.integration_tool :test_unit # which tool generates integration tests (might be overwritten automatically if using rspec-rails)
       generate.system_tests :test_unit # which tool generates system tests (might be overwritten automatically if using rspec-rails)
       generate.resource_controller :controller # which generator generates a controller when using bin/rails generate resource
       generate.resource_route true # generate a resource route definition
       generate.scaffold_controller :vite_react
       generate.stylesheets true # generate stylesheets
       generate.stylesheet_engine :css # configures the stylesheet engine (for e.g. sass) to be used when generating assets. Defaults to :css.
       generate.scaffold_stylesheet true # creates scaffold.css when generating a scaffolded resource. Defaults to true.
       generate.template_engine nil #to skip views
     end
  end
end

