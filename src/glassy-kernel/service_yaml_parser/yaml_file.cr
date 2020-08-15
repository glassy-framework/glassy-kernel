require "yaml"
require "./service_definition"

module Glassy::Kernel
  class ServiceYamlParser
    class YamlFile
      include YAML::Serializable

      property services : Hash(String, ServiceDefinition)

      property tag_restrictions : Hash(String, String)?
    end
  end
end
