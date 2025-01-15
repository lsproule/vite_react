# lib/generators/ui/component/component_generator.rb

module Ui
  class ComponentGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)
    desc "Generates a new React component (TSX) and registers it in turbo-mount.js"

    def create_component_file
      # Create a new TSX file in app/javascript/components
      template "component.tsx.erb", "app/javascript/components/#{class_name}.tsx"
    end

    def add_import_to_turbo_mount
      # Inject an import statement into turbo-mount.js after the registerComponent import
      inject_into_file(
        "app/javascript/entrypoints/turbo-mount.js",
        after: 'import { registerComponent } from "turbo-mount/react";'
      ) do
        "\nimport { #{class_name} } from \"@/components/#{class_name}\";"
      end
    end

    def register_component_in_turbo_mount
      # Append a registerComponent call at the bottom of turbo-mount.js
      append_to_file "app/javascript/entrypoints/turbo-mount.js", <<~JS

        registerComponent(turboMount, "#{class_name}", #{class_name});
      JS
    end
  end
end
