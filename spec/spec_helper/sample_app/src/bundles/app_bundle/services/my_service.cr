require "./my_logger_service"

class MyService
  def initialize(@logger : MyLoggerService, @port : Int32)
  end

  def say_hello
    "Hello"
  end

  def get_port
    @port
  end
end
