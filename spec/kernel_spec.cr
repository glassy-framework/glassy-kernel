require "./spec_helper/sample_app/src/app_kernel"

describe Glassy::Kernel::Kernel do
  it "should make container" do
    Dir.cd "#{__DIR__}/spec_helper/sample_app" do
      kernel = AppKernel.new
      kernel.container.app_my_service.say_hello.should eq("Hello")
      kernel.container.app_my_service.get_port.should eq(80)
      kernel.bundle_names.should eq ["AppBundle", "OtherBundle"] of String

      context = Glassy::Kernel::Context.new
      context.set("str_list", ["a", "b", "c"])

      service = kernel.container.echo_array_service(context)

      service.echo.should eq ["a", "b", "c"]
    end
  end
end
