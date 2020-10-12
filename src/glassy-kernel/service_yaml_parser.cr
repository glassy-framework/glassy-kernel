require "yaml"
require "./service_yaml_parser/yaml_file"

module Glassy::Kernel
  class ServiceYamlParser
    def initialize(@content_text : String)
    end

    def make_code
      yaml_file = YamlFile.from_yaml(@content_text)

      result = ""

      getters_by_tag = {} of String => Array(String)

      yaml_file.services.each do |name, service_def|
        getter_name = "#{name.gsub(".", "_")}"

        result += "@#{getter_name} : #{service_def.klass}?\n"
        result += "def #{getter_name}(context : Context? = nil) : #{service_def.klass}\n"
        result += "  unless @#{getter_name}.nil?\n"
        result += "    return @#{getter_name}.not_nil!\n"
        result += "  end\n"
        result += "  instance = #{getter_name}_builder.make(context)\n"
        if service_def.singleton
          result += "  @#{getter_name} = instance\n"
        end
        result += "  instance\n"
        result += "end\n"
        result += "\n"
        result += "def #{getter_name}=(instance)\n"
        result += "  @#{getter_name} = instance\n"
        result += "end\n"

        result += "\n"

        result += make_builder_code(getter_name, service_def, yaml_file)
        result += make_tag_builder_code(getter_name, service_def, yaml_file)

        tags = service_def.tag
        if tags.is_a?(Array)
          tags.each do |tag|
            unless getters_by_tag.has_key?(tag)
              getters_by_tag[tag] = [] of String
            end

            getters_by_tag[tag] << getter_name
          end
        end
        result += "\n"
      end

      tags = yaml_file.tags

      if tags
        tags.each do |name, definition|
          getters = getters_by_tag.fetch(name, nil)

          if getters.nil?
            getters = [] of String
          end

          builder_getters = getters.map { |g| "#{g}_tag_builder" }
          builder_klass = "Builder(#{definition.restriction})"

          getters = getters.map { |g| "#{g}(context).as(#{definition.restriction})" }
          builder_getters = builder_getters.map { |g| "#{g}(context).as(#{builder_klass})" }

          method_preffix = name.gsub(".", "_")

          result += "def #{method_preffix}_list(context : Context? = nil) : Array(#{definition.restriction})\n"
          result += "  [#{getters.join(", ")}] of #{definition.restriction}\n"
          result += "end\n"
          result += "\n"

          result += "def #{method_preffix}_builder_list(context : Context? = nil) : Array(#{builder_klass})\n"
          result += "  [#{builder_getters.join(", ")}] of #{builder_klass}\n"
          result += "end\n"
          result += "\n"
        end
      end

      result
    end

    def make_builder_code(getter_name, service_def, yaml_file)
      builder_klass = "Builder(#{service_def.klass})"

      result = ""
      result += "def #{getter_name}_builder(context : Context? = nil) : #{builder_klass}\n"
      result += "  #{builder_klass}.new(->(context : Context) {\n"
      result += "    #{service_def.klass}.new"
      result += make_initialize_code(service_def)
      result += "  }, context)\n"
      result += "end\n"

      return result
    end

    def make_tag_builder_code(getter_name, service_def, yaml_file)
      builder_klass = "Builder(#{service_def.klass})"
      builder_klass_return_type = nil

      tags = service_def.tag

      unless tags.nil?
        tags.each do |tag|
          unless yaml_file.tags.nil? || yaml_file.tags.not_nil![tag]?.nil?
            tag_def = yaml_file.tags.not_nil![tag]

            if tag_def.restriction
              builder_klass = "Builder(#{tag_def.restriction})"
              builder_klass_return_type = tag_def.restriction
            end
          end
        end
      end

      result = ""

      unless builder_klass_return_type.nil?
        result += "def #{getter_name}_tag_builder(context : Context? = nil) : #{builder_klass}\n"
        result += "  #{builder_klass}.new(->(context : Context) {\n"
        result += "    #{service_def.klass}.new"
        result += make_initialize_code(service_def, builder_klass_return_type)
        result += "  }, context)\n"
        result += "end\n"
      end

      return result
    end

    def make_initialize_code(service_def, cast_return_type : String? = nil)
      result = ""
      kwargs = service_def.kwargs
      if kwargs
        result += "(\n"
        kwargs.each do |arg_name, arg_value|
          if arg_value.starts_with?("@")
            arg_value = arg_value.sub("@", "").gsub(".", "_") + "(context)"
          elsif match = /%([^:]+)(:([^%]+))?%/.match(arg_value)
            param_key = match[1]
            param_type = match[3]?

            if match2 = /^context\(([^)]+)\)$/.match(param_key)
              suffix = ""

              if param_type
                suffix = ".as(#{param_type})"
              end

              context_key = match2[1]
              arg_value = "context.get?(\"#{context_key}\")#{suffix}"
            else
              if param_type.nil?
                suffix = ""
              else
                if param_type.includes?("?")
                  param_type = param_type.sub("?", "")
                  suffix = ""
                else
                  param_type = param_type.sub("?", "")
                  suffix = ".not_nil!"
                end
              end

              if param_type
                arg_value = "@config.get_#{param_type}(\"#{param_key}\")#{suffix}"
              else
                arg_value = "@config.get(\"#{param_key}\")"
              end
            end
          else
            arg_value = "\"#{arg_value}\""
          end
          result += "      #{arg_name}: #{arg_value},\n"
        end

        if cast_return_type
          result += "    ).as(#{cast_return_type})\n"
        else
          result += "    )\n"
        end
      else
        result += "\n"
      end

      return result
    end
  end
end
