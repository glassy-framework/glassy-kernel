# glassy-kernel

DI (Dependency Injection) Container for the Glassy Framework, based in bundles.

Inspired by: [phoopy](https://github.com/phoopy/phoopy)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     glassy-kernel:
       github: glassy-framework/glassy-kernel
   ```

2. Run `shards install`

## Usage

Create a dependency file, ex: config/services.yml
```yml
services:
  my_object:
    class: MyClass
    kwargs:
      logger: '@logger'
    tag:
      - my_tag_example
  
  logger:
    class: MyLogger
```

Implement these classes as you like. After that you can implement the container as below.

```crystal
require "glassy-kernel"

class AppBundle < Glassy::Kernel::Bundle
  SERVICES_PATH = "#{__DIR__}/config/services.yml"
end

class AppKernel < Glassy::Kernel::Kernel
  register_bundles [
    AppBundle
  ]
end

kernel = AppKernel.new
kernel.container.my_object.say_hello
```

## Development

Always run crystal spec to execute the tests

## Contributing

1. Fork it (<https://github.com/glassy-framework/glassy-kernel/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anderson Danilo](https://github.com/andersondanilo) - creator and maintainer
