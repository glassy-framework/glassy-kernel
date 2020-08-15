require "./yaml_merger"
require "./service_yaml_parser"

files = ARGV[0].split("|")

contents = files.map do |fname|
  File.read(fname)
end

final_content = Glassy::Kernel::YamlMerger.new(contents).merge
code = Glassy::Kernel::ServiceYamlParser.new(final_content).make_code

puts code
