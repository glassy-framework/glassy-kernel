require "./container"
require "./config"
require "./bundle"

module Glassy::Kernel
  class Kernel
    macro register_bundles(bundles)
      def initialize
        @config = Glassy::Kernel::Config.new(config_paths)
        @container = Container.new(@config)
      end

      def container
        @container
      end

      def config_paths : Array(String)
        return [
          "config/parameters.yml"
        ]
      end

      class Container < Glassy::Kernel::Container
        load_service_paths([
          {% for bundle in bundles %}
            {{bundle.resolve.id}}::SERVICES_PATH,
          {% end %}
        ])
      end
    end
  end
end
