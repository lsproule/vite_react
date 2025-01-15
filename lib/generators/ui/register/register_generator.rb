# lib/generators/ui/register/register_generator.rb

module Ui
  class RegisterGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)
    desc "Takes an existing TSX component and auto-registers it in turbo-mount.js"

    def ensure_component_exists
      unless File.exist?("app/javascript/components/#{class_name}.tsx")
        say "ERROR: app/javascript/components/#{class_name}.tsx not found!", :red
        exit(1) # or raise an exception
      end
    end

    def add_import_to_turbo_mount
      # Step 1: Inject an import line under the registerComponent import line
      inject_into_file(
        "app/javascript/entrypoints/turbo-mount.js",
        after: 'import { registerComponent } from "turbo-mount/react";'
      ) do
        "\nimport { #{class_name} } from \"@/components/#{class_name}\";"
      end
    end

    def register_component_in_turbo_mount
      # Step 2: Append the registerComponent call at the bottom of turbo-mount.js
      append_to_file "app/javascript/entrypoints/turbo-mount.js", <<~JS

        registerComponent(turboMount, "#{class_name}", #{class_name});
      JS
    end
  end
end
