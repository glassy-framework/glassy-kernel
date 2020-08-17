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
            arg_value = arg_value.sub("@", "")
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

      getters_by_tag.each do |tag, getters|
        restriction = nil
        tags = yaml_file.tags
        if tags
          tag_def = tags.fetch(tag, nil)

          if tag_def
            result += "def #{tag}_list : Array(#{tag_def.restriction})\n"
            result += "  [#{getters.join(", ")}] of #{tag_def.restriction}\n"
            result += "end\n"
            result += "\n"
          end
        end
      end

      result
    end
  end
end
