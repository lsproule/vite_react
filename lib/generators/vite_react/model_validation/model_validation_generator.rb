# lib/generators/rails/tmodel_validation/model_validation_generator.rb

module ViteReact
  module Generators
    class ModelValidationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def update_types_for_validations
        require File.join(Rails.root, "app/models/\#{file_path}.rb")

        model_class = file_name.camelize.constantize

        presence_attributes = model_class.validators
          .select { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
          .flat_map(&:attributes)
          .map(&:to_s)

        required_belongs_tos = model_class.reflect_on_all_associations(:belongs_to)
          .select { |assoc| assoc.options[:optional] == false || assoc.options[:required] == true }
          .map(&:name)
          .map(&:to_s)

        presence_required = presence_attributes.to_set
        required_belongs_tos.each do |assoc_name|
          presence_required << assoc_name        # e.g. user
          presence_required << "\#{assoc_name}_id" # e.g. user_id
        end

        types_file_path = Rails.root.join("app/javascript/types.d.ts")
        return unless File.exist?(types_file_path)

        lines = File.read(types_file_path).split("\n")


        in_target_interface = false
        brace_depth = 0


        start_of_interface_regex = /^\s*(?:export\s+)?interface\s+\#{Regexp.escape(model_class.name)}\s*(\{|extends|$)/

        lines.map!.with_index do |line, idx|
          if !in_target_interface && line =~ start_of_interface_regex
            in_target_interface = true
            brace_depth = line.count("{")
            # {'      '}
          elsif in_target_interface
            brace_depth += line.count("{")
            brace_depth -= line.count("}")
            # {'        '}
            if brace_depth <= 0
              in_target_interface = false
            end
          end

          if in_target_interface && brace_depth > 0
            if line =~ /^(\s*)([a-zA-Z_0-9]+)(\??):/
              leading_spaces = $1
              attribute_name = $2
              question_mark  = $3 # could be "" or "?"

              if presence_required.include?(attribute_name)
                line = line.sub("\#{attribute_name}?:", "\#{attribute_name}:")
              else
                unless question_mark == "?"
                  line = line.sub("\#{attribute_name}:", "\#{attribute_name}?:")
                end
              end
            end
          end

          line
        end

        File.write(types_file_path, lines.join("\n"))
      end
    end
  end
end
