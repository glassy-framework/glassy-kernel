module Glassy::Kernel
  class Container
    macro load_service_paths(service_paths)
      {{ run("#{__DIR__}/generate_container", service_paths.map { |s| s.resolve }.join('|')) }}
    end
  end
end
