require 'yaml'
require 'eiscp/receiver'
require 'ostruct'

module Command

  @@yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
  @@yaml_object = YAML.load(File.read(@@yaml_file_path))
  @@modelsets = @@yaml_object["modelsets"]
  @@yaml_object.delete("modelsets")
  @@zones = @@yaml_object.map{|k, v| k}
  @@zones.each {|zone| class_variable_set("@@#{zone}", nil) }
  @@main = @@yaml_object['main']

  def self.command_to_name(command)
    return @@main[command]['name']
  end

  def self.name_to_command(name)
    @@main.each_pair do |command, attrs|
      if attrs['name'] == name
        return command
      end
    end
  end

  def self.command_value_to_value_name(command, value)
    return @@main[command]['values'][value]['name'] 
  end

  def self.command_value_name_to_value(command, name)
    @@main[command]['values'].each do |k, v|
      if v['name'] == name.to_s
        return k
      end
    end
  end


  def self.description_from_name(name)
    @@main.each_pair do |command, attrs|
      if attrs['name'] == name
        return command['description']
      end
    end
  end

  def self.description_from_command(command)
    return @@main[command]['description']
  end

  def self.description_from_command_value(command, value)
    return @@main[command]['values'].select do |k, v| 
      if k == value
        return v['description']
      end
    end
  end

  def self.list_all_commands
    @@main.each_pair do |command, attrs|
      puts "#{command} - #{attrs['name']}: #{attrs['description']}"
      attrs['values'].each_pair do |k, v|
        puts "--#{k}:#{v}"
      end
    end
  end

  def self.list_compatible_commands

  end
end

