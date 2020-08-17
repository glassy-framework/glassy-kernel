require "yaml"

module Glassy::Kernel
  class ServiceYamlParser
    class ServiceDefinition
      include YAML::Serializable

      @[YAML::Field(key: "class")]
      property klass : String

      property tag : Array(String)?

      property kwargs : Hash(String, String)?
    end
  end
end
