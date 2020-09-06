require "yaml"
require "./yaml_merger"

module Glassy::Kernel
  class Config
    @data : YAML::Any

    def initialize(file_paths : Array(String))
      contents = file_paths.select { |n| File.exists?(n) }.map do |file_path|
        File.read(file_path)
      end

      if contents.size == 0
        raise "No file found (#{file_paths.join(", ")})"
      end

      initialize(YamlMerger.new(contents).merge)
    end

    def initialize(text : String)
      @data = YAML.parse(text)
    end

    def get(key : String, default : String? = nil) : String?
      get_s(key, default)
    end

    def get_String(key : String, default : String? = nil) : String?
      get_s(key, default)
    end

    def get_s(key : String, default : String? = nil) : String?
      get_path(key).try(&.as_s?) || default
    end

    def get_Float32(key : String, default : Float32? = nil) : Float32?
      get_f(key, default)
    end

    def get_f(key : String, default : Float32? = nil) : Float32?
      get_path(key).try(&.as_f32?) || default
    end

    def get_Int32(key : String, default : Int32? = nil) : Int32?
      get_i(key, default)
    end

    def get_i(key : String, default : Int32? = nil) : Int32?
      begin
        return get_path(key).try(&.as_i) || default
      rescue TypeCastError
        str = get_s(key)
        if str && str.size > 0
          return str.to_i
        else
          return default
        end
      end
    end

    def get_Bool(key : String, default : Bool? = nil) : Bool?
      get_bool(key, default)
    end

    def get_bool(key : String, default : Bool? = nil) : Bool?
      begin
        str = get_path(key).try(&.as_s)
        value = str == "true" || str == "1"
      rescue TypeCastError
        value = get_path(key).try(&.as_bool)
        if value.nil?
          value = default
        end
      end

      return value
    end

    private def get_path(path : String) : YAML::Any?
      path = "parameters.#{path}"
      pieces = path.split(".")
      result = @data

      while key = pieces.shift?
        if result
          result = result[key]?
        end
      end

      begin
        s_result = result.try(&.as_s)

        if s_result
          if match = /%env\(([^,]+)(, *([^)]+))?\)%/.match(s_result)
            value = ENV[match[1]]?
            if value.nil? && match[3]?
              value = match[3]
            end
            result = YAML::Any.new(value)
          end
        end
      rescue TypeCastError
      end

      return result
    end
  end
end
