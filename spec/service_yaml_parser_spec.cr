require "./spec_helper"
require "../src/glassy-kernel/service_yaml_parser"

describe Glassy::Kernel::ServiceYamlParser do
  it "should make code" do
    content_text = <<-END
      services:
        logger:
          class: MyClass
          tag:
            - log

        my_service:
          class: MyService
          kwargs:
            logger: '@logger'
            name: 'my name'
            port: '%http.port:Int32%'
            port_opt: '%http.port:Int32?%'
            other: '%other%'

      tags:
        log:
          restriction: MyClass
    END

    parser = Glassy::Kernel::ServiceYamlParser.new(content_text)
    code = parser.make_code
    expected = <<-END
    def logger
      @logger ||= MyClass.new
    end

    def my_service
      @my_service ||= MyService.new(
        logger: logger,
        name: "my name",
        port: @config.get_Int32("http.port").not_nil!,
        port_opt: @config.get_Int32("http.port"),
        other: @config.get("other"),
      )
    end

    def log_list : Array(MyClass)
      [logger] of MyClass
    end
    END
    code.should eq(expected + "\n\n")
  end
end
