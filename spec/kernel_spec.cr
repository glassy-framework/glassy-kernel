require "./spec_helper/sample_app/src/app_kernel"

describe Glassy::Kernel::Kernel do
  it "should make container" do
    kernel = AppKernel.new
    kernel.container.my_service.say_hello.should eq("Hello")
  end
end
