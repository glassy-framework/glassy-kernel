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
      )
    end

    def log_list : Array(MyClass)
      [logger] of MyClass
    end
    END
    code.should eq(expected + "\n\n")
  end
end
