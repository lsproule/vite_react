require "rails/generators/erb/scaffold/scaffold_generator"
require "rails/generators/resource_helpers"

module ViteReact
  module Generators
    class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path("templates", __dir__)
      source_paths << "lib/templates/erb/scaffold"

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          formats.each do |format|
            filename = filename_with_extensions(view, format)
            template filename, File.join("app/views", controller_file_path, filename)
          end
        end

        template "partial.html.erb", File.join("app/views", controller_file_path, "_#{singular_name}.html.erb")
      end


      def create_or_update_types
        types_file_path = Rails.root.join("app/javascript/types.d.ts")
        interface_code  = generate_interface_code

        if File.exist?(types_file_path)
          append_to_file types_file_path, interface_code
        else
          create_file types_file_path, interface_code
        end
      end

      def generate_interface_code
        attributes_lines = attributes.flat_map do |attr|
          if attr.type == :references
            build_ts_reference_lines(attr)
          else
            [ build_ts_attribute_line(attr) ]
          end
        end

        <<~TS
          // AUTO-GENERATED by rails g scaffold #{file_name}
          interface #{class_name} {
            #{attributes_lines.join("\n\t")}
          }
        TS
      end
      private
        def build_ts_attribute_line(attr)
          "#{attr.name}?: #{rails_to_ts_type(attr.type)};"
        end

        def build_ts_reference_lines(attr)
          referenced_interface_name = attr.name.camelize
          [
            "#{attr.name}_id: number;",
            "#{attr.name}?: #{referenced_interface_name};"
          ]
        end

        def rails_to_ts_type(rails_type)
          case rails_type.to_s
          when "integer", "float", "decimal" then "number"
          when "boolean"                     then "boolean"
          else
            "string"
          end
        end
        def available_views
          %w[index edit show new _form]
        end
    end
  end
end

