class EchoArrayService
  def initialize(@arr : Array(String))
  end

  def echo
    @arr
  end
end
