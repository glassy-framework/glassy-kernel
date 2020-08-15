require "./my_logger_service"

class MyService
  def initialize(@logger : MyLoggerService)
  end

  def say_hello
    "Hello"
  end
end
