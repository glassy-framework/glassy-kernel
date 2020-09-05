module Glassy::Kernel
  abstract class Container
    def initialize(@config : Glassy::Kernel::Config)
      @config
    end

    macro load_service_paths(service_paths)
      {{ run("#{__DIR__}/generate_container", service_paths.map { |s| s.resolve }.join('|')) }}
    end

    def container
      self
    end

    def config
      @config
    end
  end
end
