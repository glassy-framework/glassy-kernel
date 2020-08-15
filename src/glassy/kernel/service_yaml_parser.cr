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

        args = service_def.args
        args_texts = [] of String

        if args.is_a?(Array)
          args_texts = args.map do |arg|
            arg.gsub("@", "")
          end
        end

        new_suffix = args_texts.size > 0 ? "(#{args_texts.join(", ")})" : ""

        result += "def #{getter_name}\n"
        result += "  @#{name} ||= #{service_def.klass}.new#{new_suffix}\n"
        result += "end\n"

        tags = service_def.tags
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
        tag_restrictions = yaml_file.tag_restrictions

        if tag_restrictions.is_a?(Hash)
          restriction = tag_restrictions.fetch(tag, nil)
        end

        suffix = ""

        if restriction
          suffix = " : Array(#{restriction})"
        end

        result += "def list_#{tag}#{suffix}\n"
        result += "  [#{getters.join(", ")}]\n"
        result += "end\n"
        result += "\n"
      end

      result
    end
  end
end
