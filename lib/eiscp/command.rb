require 'yaml'
require_relative './receiver'
require 'ostruct'

module EISCP
  module Command

    DEFAULT_ZONE = 'main'
    @@yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
    @@yaml_object = YAML.load(File.read(@@yaml_file_path))
    @@modelsets = @@yaml_object["modelsets"]
    @@yaml_object.delete("modelsets")
    @@zones = @@yaml_object.map{|k, v| k}
    @@zones.each {|zone| class_variable_set("@@#{zone}", nil) }
    @@main = @@yaml_object['main']
    @@zone_modules = {}


    @@yaml_object.each_key do |zone|
      @@yaml_object[zone].each do |command|
        @@yaml_object[zone][command]['values'].each do |value|
       
          if value.is_a? Array
            create_range_commands(zone, command, value)
          elsif value.match(/(B|T){xx}/)
            create_treble_bass_commands(zone, command, value)
          elsif value.match(/{xx}/)
            create_balance_commands(zone, command, value)
          end
        end
      end
    end

    def create_range_commands(zone, command, value)
      case value.count
      when 3
        range = Range.new(value[0], value[2])
      when 2
        range = Range.new(*value)
      end
      range.each do |value|
        @@yaml_object[zone][command]['values'][value.to_s(16).upcase] = {
          "name" => value.to_s,
          "description" => @@yaml_object[zone][command]['values'][value.to_s]['description'],
          "models" => @@yaml_object[zone][command]['values'][value.to_s]['models'],
        }
      end
    end

    def create_treble_bass_commands(zone, command, value)
      ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
        @@yaml_object[zone][command]['values'][value[0] + v] = {
          "name" => @@yaml_object[zone][command]['values'][value[0] + '{xx}']['name'],
          "description" => @@yaml_object[zone][command]['values'][value[0] + '{xx}']['description'],
          "models" => @@yaml_object[zone][command]['values'][value[0] + '{xx}']['models']
        }
      end
    end

    def create_balance_commands(zone, command, value)

    end


    def zone_module(name, options={}, &block)
      @@zone_modules[name] = Class.new(options[:base] || EISCP::Zone, &block)
    end

    def self.command_to_name(command, zone = DEFAULT_ZONE)
      return @@main[command]['name']
    end

    def self.command_name_to_command(name, zone = DEFAULT_ZONE)
      @@yaml_object[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return command
        end
      end
    end

    def self.command_value_to_value_name(command, value, zone = DEFAULT_ZONE)
      return @@yaml_object[zone][command]['values'][value]['name'] 
    end

    def self.command_value_name_to_value(command, name, zone = DEFAULT_ZONE)
      @@yaml_object[zone][command]['values'].each do |k, v|
        if v['name'] == name.to_s
          return k
        end
      end
    end


    def self.description_from_command_name(name, zone = DEFAULT_ZONE)
      @@yaml_object[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return @@main[command]['description']
        end
      end
    end

    def self.description_from_command(command, zone = DEFAULT_ZONE)
      return @@yaml_object[zone][command]['description']
    end

    def self.description_from_command_value(command, value, zone = DEFAULT_ZONE)
      return @@yaml_object[zone][command]['values'].select do |k, v| 
        if k == value
          return v['description']
        end
      end
    end

    def self.list_all_commands
      @@yaml_object.each do |zone|
        @@yaml_object[zone].each_pair do |command, attrs|
          puts "#{command} - #{attrs['name']}: #{attrs['description']}"
          attrs['values'].each_pair do |k, v|
            puts "--#{k}:#{v}"
          end
        end
      end
    end

    def self.list_compatible_commands(modelstring)
      sets = [] 
      @@modelsets.each_pair do |set, array|
        if array.include? modelstring
          sets << set
        end
      end
      return sets
    end

    def self.parse(string)
      array = string.split(" ")
      zone = DEFAULT_ZONE
      command_name = ''
      value_name = ''
      if array.count == 3
        zone = array.shift
        command_name = array.shift
        value_name = array.shift
      elsif array.count == 2
        command_name = array.shift
        value_name = array.shift
      end
      command = command_name_to_command(command_name)
      value = command_value_name_to_value(command, value_name)
      return EISCP::Message.new(command, value)
    end
  end
end
