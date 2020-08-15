require "./container"
require "./bundle"

module Glassy::Kernel
  class Kernel
    macro register_bundles(bundles)
      def initialize
        @container = Container.new
      end

      def container
        @container
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

