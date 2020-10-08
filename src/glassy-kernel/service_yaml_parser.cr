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

        result += "def #{getter_name}(context : Context? = nil) : #{service_def.klass}\n"
        if service_def.singleton
          result += "  @#{getter_name} ||= #{getter_name}_builder.make(context)\n"
        else
          result += "  #{getter_name}_builder.make(context)\n"
        end
        result += "end\n"

        result += "\n"

        result += "def #{getter_name}_builder(context : Context? = nil) : Builder(#{service_def.klass})\n"
        result += "  Builder(#{service_def.klass}).new(->(context : Context) {\n"
        result += "    #{service_def.klass}.new"

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
          result += "    )\n"
        else
          result += "\n"
        end
        result += "  }, context)\n"
        result += "end\n"

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

          builder_getters = getters.map { |g| "#{g}_builder" }

          getters = getters.map { |g| "#{g}(context)" }
          builder_getters = builder_getters.map { |g| "#{g}(context)" }

          result += "def #{name}_list(context : Context? = nil) : Array(#{definition.restriction})\n"
          result += "  [#{getters.join(", ")}] of #{definition.restriction}\n"
          result += "end\n"
          result += "\n"

          result += "def #{name}_builder_list(context : Context? = nil) : Array(Builder(#{definition.restriction}))\n"
          result += "  [#{builder_getters.join(", ")}] of Builder(#{definition.restriction})\n"
          result += "end\n"
          result += "\n"
        end
      end

      result
    end
  end
end
