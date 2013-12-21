require 'yaml'

module Command
  @@yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
  @@commands = YAML.load(File.read(@@yaml_file_path))
  @@zones = @@commands.map{|k, v| k}
  @@zones.each {|zone| class_variable_set("@@#{zone}", 0) }


end
