module Command
  @@yaml_file_path = '../eiscp-commands.yaml'
  @@commands = YAML.load(File.read(@@yaml_file_path))
  @@zones = @@commands.map{|k, v| k}
  @@zones.each {|zone| class_variable_set("__#{zone}", 0) }


end
