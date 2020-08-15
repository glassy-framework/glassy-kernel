require "./services/**"
require "../../../../../spec_helper"

class OtherBundle < Glassy::Kernel::Bundle
  SERVICES_PATH = "#{__DIR__}/config/services.yml"
end
