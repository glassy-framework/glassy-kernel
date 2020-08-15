require "./services/**"
require "../../../../../spec_helper"

class AppBundle < Glassy::Kernel::Bundle
  SERVICES_PATH = "#{__DIR__}/config/services.yml"
end
