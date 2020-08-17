require "yaml"

module Glassy::Kernel
  class ServiceYamlParser
    class TagDefinition
      include YAML::Serializable

      property restriction : String
    end
  end
end
