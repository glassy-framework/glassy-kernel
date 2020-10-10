require "./config"
require "./kernel"
require "./builder"
require "./context"

module Glassy::Kernel
  abstract class Container
    alias Context = Glassy::Kernel::Context
    alias Builder = Glassy::Kernel::Builder

    def initialize(@config : Glassy::Kernel::Config, @kernel : Glassy::Kernel::Kernel)
    end

    macro load_service_paths(service_paths)
      {{ run("#{__DIR__}/generate_container", service_paths.map { |s| s.resolve }.join('|')) }}
    end

    def container(context : Glassy::Kernel::Context? = nil)
      self
    end

    def config(context : Glassy::Kernel::Context? = nil)
      @config
    end

    def kernel(context : Glassy::Kernel::Context? = nil)
      @kernel
    end
  end
end
