require "./spec_helper/sample_app/src/app_kernel"

describe Glassy::Kernel::Kernel do
  it "should make container" do
    Dir.cd "#{__DIR__}/spec_helper/sample_app" do
      kernel = AppKernel.new
      kernel.container.my_service.say_hello.should eq("Hello")
      kernel.container.my_service.get_port.should eq(80)
    end
  end
end
