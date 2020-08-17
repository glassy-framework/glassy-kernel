require "yaml"
require "./service_definition"
require "./tag_definition"

module Glassy::Kernel
  class ServiceYamlParser
    class YamlFile
      include YAML::Serializable

      property services : Hash(String, ServiceDefinition)

      property tags : Hash(String, TagDefinition)?
    end
  end
end
