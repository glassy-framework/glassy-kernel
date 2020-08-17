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
        getter_name = "#{name}"

        result += "def #{getter_name}\n"
        result += "  @#{name} ||= #{service_def.klass}.new"

        kwargs = service_def.kwargs
        if kwargs
          result += "(\n"
          kwargs.each do |arg_name, arg_value|
            if arg_value.starts_with?("@")
              arg_value = arg_value.sub("@", "")
            else
              arg_value = "\"#{arg_value}\""
            end
            result += "    #{arg_name}: #{arg_value},\n"
          end
          result += "  )\n"
        else
          result += "\n"
        end

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

          result += "def #{name}_list : Array(#{definition.restriction})\n"
          result += "  [#{getters.join(", ")}] of #{definition.restriction}\n"
          result += "end\n"
          result += "\n"
        end
      end

      result
    end
  end
end
