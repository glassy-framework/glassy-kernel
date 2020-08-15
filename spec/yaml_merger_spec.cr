require "./spec_helper"
require "../src/glassy-kernel/yaml_merger"

describe Glassy::Kernel::YamlMerger do
  it "should make code" do
    content_one = <<-END
      services:
        logger:
          class: MyClass
          tags:
            - log

        my_service:
          class: MyService
          args:
            - '@logger'

      tag_restrictions:
        log: MyClass
    END

    content_two = <<-END
      services:
        other_logger:
          class: MyOtherClass
          tags:
            - log

        my_service:
          class: MyService
          args:
            - '@other_logger'

      tag_restrictions:
        nothing: MyClass
    END

    merger = Glassy::Kernel::YamlMerger.new([content_one, content_two])

    content_result = merger.merge

    content_expected = <<-END
      services:
        logger:
          class: MyClass
          tags:
            - log

        my_service:
          class: MyService
          args:
            - '@other_logger'

        other_logger:
          class: MyOtherClass
          tags:
            - log

      tag_restrictions:
        log: MyClass
        nothing: MyClass
    END

    YAML.dump(YAML.parse(content_result)).should eq(YAML.dump(YAML.parse(content_expected)))
  end
end
