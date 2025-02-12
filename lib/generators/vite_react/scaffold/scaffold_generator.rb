require "rails/generators/resource_helpers"
require "rails/generators/rails/scaffold/scaffold_generator"

module ViteReact
  module Generators
    class ScaffoldGenerator < Rails::Generators::ScaffoldControllerGenerator
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      remove_hook_for :template_engine
      # hook_for :controller

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


        def rails_to_ts_type(attribute)
          case attribute.type
          when :float, :decimal, :integer
              "number"
          when :boolean
              "boolean"
          when :attachment
              "{ filename: string; url: string }"
          when :attachments
              "{ filename: string; url: string }[]"
          else
              "string"
          end
        end
        def available_views
          %w[index edit show new _form]
        end

        def formats
          [ format ]
        end

        def format
          :html
        end

        def handler
          :erb
        end

        def filename_with_extensions(name, file_format = format)
          [ name, file_format, handler ].compact.join(".")
        end
    end
  end
end
