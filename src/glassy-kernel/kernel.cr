require "./container"
require "./config"
require "./bundle"

module Glassy::Kernel
  abstract class Kernel
    abstract def bundles : Array(BundleMetadata)

    def bundle_names : Array(String)
      bundles.map { |b| b.name }
    end

    def config_paths : Array(String)
      return [
        "config/parameters.yml",
      ]
    end

    class BundleMetadata
      getter name, instance, metadata

      def initialize(@name : String, @instance : Bundle, @metadata : Hash(String, String))
      end
    end

    macro register_bundles(bundles)
      def initialize
        @config = Glassy::Kernel::Config.new(config_paths)
        @container = Container.new(@config, self)
      end

      def container
        @container.not_nil!
      end

      def bundles : Array(BundleMetadata)
        @bundles ||= [
          {% for bundle in bundles %}
            BundleMetadata.new(
              name: "{{bundle.resolve.id}}",
              instance: {{bundle.resolve.id}}.new,
              metadata: {
                {% for const_name in bundle.resolve.constants %}
                  "{{const_name.id}}" => "{{ bundle.resolve.constant(const_name).id }}",
                {% end %}
              } of String => String
            ),
          {% end %}
        ] of BundleMetadata
      end

      class Container < Glassy::Kernel::Container
        load_service_paths([
          {% for bundle in bundles %}
            {{bundle.resolve.id}}::SERVICES_PATH,
          {% end %}
        ])

        {% for bundle in bundles %}
          {% if bundle.resolve.constant("HAS_CONTAINER_EXT") %}
            {{bundle.resolve.id}}.apply_container_ext([
              {% for bundle in bundles %}
                {{bundle.resolve.id}},
              {% end %}
            ])
          {% end %}
        {% end %}
      end
    end
  end
end
