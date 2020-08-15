require "yaml"

module Glassy::Kernel
  class YamlMerger
    def initialize(@contents : Array(String))
    end

    def merge : String
      first_content = @contents.shift
      data = YAML.parse(first_content)
      data_raw = data.raw

      @contents.each do |content|
        other_data = YAML.parse(content)
        other_data_raw = other_data.raw

        if data_raw.is_a?(Hash) && other_data_raw.is_a?(Hash)
          merge_two_hashes(data_raw, other_data_raw)
        end
      end

      YAML.dump(data)
    end

    private def merge_two_hashes(first : Hash, second : Hash)
      second.each do |key, value|
        value_raw = value.raw

        if value_raw.is_a?(Hash)
          first_any_value = first[key]?

          if first_any_value.nil?
            first[key] = value
          else
            first_value = first_any_value.raw

            if first_value.is_a?(Hash)
              merge_two_hashes(first_value, value_raw)
            end
          end
        else
          first[key] = value
        end
      end
    end
  end
end
