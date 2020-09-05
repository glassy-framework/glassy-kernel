require "./spec_helper"

describe Glassy::Kernel::Config do
  it "get parameters" do
    ENV["MY_ENV"] = "my value"
    ENV["MY_PORT"] = "80"

    config = Glassy::Kernel::Config.new(<<-END
      parameters:
        test_string: 'My test string'
        test_true_1: true
        test_false_1: false
        test_true_2: 'true'
        test_false_2: 'false'
        test_int: 5
        test_float: 4.5
        test_env_s: '%env(MY_ENV)%'
        test_env_i: '%env(MY_PORT)%'
        test_env_default_i: '%env(MY_NOT_EXIST, 50)%'
        test_env_default_s: '%env(MY_NOT_EXIST, My Name)%'

        depth:
          test_string: 'My deep string'
    END
    )

    config.get_s("test_string").should eq("My test string")
    config.get_s("depth.test_string").should eq("My deep string")
    config.get_bool("test_true_1").should be_true
    config.get_bool("test_false_1").should be_false
    config.get_bool("test_true_2").should be_true
    config.get_bool("test_false_2").should be_false
    config.get_i("test_int").should eq 5
    config.get_f("test_float").should eq 4.5
    config.get_s("test_env_s").should eq "my value"
    config.get_i("test_env_i").should eq 80
    config.get_i("test_env_default_i").should eq 50
    config.get_s("test_env_default_s").should eq "My Name"
  end
end
