require 'yaml'

module Command
  @@yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
  @@commands = YAML.load(File.read(@@yaml_file_path))
  @@modelsets = @@commands["modelsets"]
  @@commands.delete("modelsets")
  @@zones = @@commands.map{|k, v| k}
  @@zones.each {|zone| class_variable_set("@@#{zone}", nil) }






end
