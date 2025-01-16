# lib/generators/rails/migration_ts/migration_ts_generator.rb
require "rails/generators/migration/migration_generator"
require "rails/generators/resource_helpers"



module ViteReact
  module Generators
    class MigrationGenerator < MigrationGenerator
      source_root File.expand_path("templates", __dir__)

      argument :migration_name, type: :string
      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def update_types
        puts "Updating TypeScript definitions based on #{migration_name}..."

        types_file_path = Rails.root.join("app/javascript/types.d.ts")
        # read the file, parse it, inject new columns if they don’t exist, etc.
        # For references, do the same logic we did in the scaffold generator

        interface_code = build_migration_interface_snippet

        append_to_file types_file_path, interface_code
      end

      private

      def build_migration_interface_snippet
        # This is obviously simplistic. You would incorporate something
        # like the logic from your main TS generator, or even call
        # a shared module that does the same parsing of attributes.
        attributes_lines = attributes.flat_map do |attr|
          if attr.type == "references"
            [
              "#{attr.name}_id: number;",
              "#{attr.name}?: #{attr.name.camelize};"
            ]
          else
            [ "#{attr.name}?: #{rails_to_ts_type(attr.type)};" ]
          end
        end

        <<~TS
      // AUTO-GENERATED by rails g migration #{migration_name}
      // You may need to update validations or remove ? accordingly
      // if presence validations exist.
      // Changes introduced by: #{migration_name}
      #{attributes_lines.join("
        ")}
        TS
      end

      def rails_to_ts_type(rails_type)
        case rails_type
        when "integer", "float", "decimal" then "number"
        when "boolean" then "boolean"
        else "string"
        end
      end
    end
  end
end
