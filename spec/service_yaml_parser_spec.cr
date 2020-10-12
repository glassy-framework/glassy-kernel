require "./spec_helper"
require "../src/glassy-kernel/service_yaml_parser"

describe Glassy::Kernel::ServiceYamlParser do
  it "should make code" do
    content_text = <<-END
      services:
        app.logger:
          class: MyClass
          singleton: true
          tag:
            - log

        app.my_service:
          class: MyService
          kwargs:
            logger: '@app.logger'
            name: 'my name'
            port: '%http.port:Int32%'
            port_opt: '%http.port:Int32?%'
            other: '%other%'
            langs: '%context(accepted_languages):Array(String)%'

      tags:
        log:
          restriction: MyClass
    END

    parser = Glassy::Kernel::ServiceYamlParser.new(content_text)
    code = parser.make_code
    expected = <<-END
    @app_logger : MyClass?
    def app_logger(context : Context? = nil) : MyClass
      unless @app_logger.nil?
        return @app_logger.not_nil!
      end
      instance = app_logger_builder.make(context)
      @app_logger = instance
      instance
    end

    def app_logger=(instance)
      @app_logger = instance
    end

    def app_logger_builder(context : Context? = nil) : Builder(MyClass)
      Builder(MyClass).new(->(context : Context) {
        MyClass.new
      }, context)
    end
    def app_logger_tag_builder(context : Context? = nil) : Builder(MyClass)
      Builder(MyClass).new(->(context : Context) {
        MyClass.new
      }, context)
    end

    @app_my_service : MyService?
    def app_my_service(context : Context? = nil) : MyService
      unless @app_my_service.nil?
        return @app_my_service.not_nil!
      end
      instance = app_my_service_builder.make(context)
      instance
    end

    def app_my_service=(instance)
      @app_my_service = instance
    end

    def app_my_service_builder(context : Context? = nil) : Builder(MyService)
      Builder(MyService).new(->(context : Context) {
        MyService.new(
          logger: app_logger(context),
          name: "my name",
          port: @config.get_Int32("http.port").not_nil!,
          port_opt: @config.get_Int32("http.port"),
          other: @config.get("other"),
          langs: context.get?("accepted_languages").as(Array(String)),
        )
      }, context)
    end

    def log_list(context : Context? = nil) : Array(MyClass)
      [app_logger(context).as(MyClass)] of MyClass
    end

    def log_builder_list(context : Context? = nil) : Array(Builder(MyClass))
      [app_logger_tag_builder(context).as(Builder(MyClass))] of Builder(MyClass)
    end
    END

    File.write "/tmp/actual", code

    code.should eq(expected + "\n\n")
  end
end
