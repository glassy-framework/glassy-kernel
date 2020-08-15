require "yaml"

module Glassy::Kernel
  class ServiceYamlParser
    class ServiceDefinition
      include YAML::Serializable

      @[YAML::Field(key: "class")]
      property klass : String

      property tags : Array(String)?

      property args : Array(String)?
    end
  end
end
