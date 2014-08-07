require 'yaml'
require_relative './receiver'
require 'ostruct'

module EISCP
  module Command

    # Assume we're talking about the 'main' zone unless otherwise specified.
    DEFAULT_ZONE = 'main'
    @yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
    @yaml_object = YAML.load(File.read(@yaml_file_path))
    @modelsets = @yaml_object["modelsets"]
    @yaml_object.delete("modelsets")
    @zones = @yaml_object.map{|k, v| k}

    # Return the zone that includes the given command
    def self.zone_from_command(command)
      @zones.each do |zone|
        @yaml_object[zone].each_pair do |k, v|
          if command == k
            return zone
          end
        end
      end
      return nil
    end

    # Return the human readable name of a command
    def self.command_to_name(command)
      zone = zone_from_command(command)
      return @yaml_object[zone][command]['name']
    end

    # Return the command from a given command name
    def self.command_name_to_command(name, zone)
      @yaml_object[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return command
        end
      end
    end

    # Return a command value name from a command and value
    def self.command_value_to_value_name(command, value)
      zone = zone_from_command(command)
      return @yaml_object[zone][command]['values'][value]['name'] 
    end

    # Return a command value from a command and value name
    def self.command_value_name_to_value(command, value_name)
      zone = zone_from_command(command)
      @yaml_object[zone][command]['values'].each_pair do |k, v|
        if v['name'] == value_name.to_s
          return k
        end
      end
    end

    # Return a description form a command name and zone
    def self.description_from_command_name(name, zone)
      @yaml_object[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return @yaml_object[zone][command]['description']
        end
      end
    end

    # Return a description from a command
    def self.description_from_command(command)
      zone = zone_from_command(command)
      return @yaml_object[zone][command]['description']
    end

    # Return a description from a command and value
    def self.description_from_command_value(command, value)
      zone = zone_from_command(command)
      return @yaml_object[zone][command]['values'].select do |k, v| 
        if k == value
          return v['description']
        end
      end
    end

    # Return a list of all commands
    def self.list_all_commands
      @yaml_object.each_pair do |zone, commands|
        @yaml_object[zone].each_pair do |command, attrs|
          puts "#{command} - #{attrs['name']}: #{attrs['description']}"
          attrs['values'].each_pair do |k, v|
            puts "--#{k}:#{v}"
          end
        end
      end
    end

    # Return a list of commands compatible with a given model
    def self.list_compatible_commands(modelstring)
      sets = [] 
      @modelsets.each_pair do |set, array|
        if array.include? modelstring
          sets << set
        end
      end
      return sets
    end

    # Parse a command and return a message object
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
      begin
        command = command_name_to_command(command_name, zone)
        value = command_value_name_to_value(command, value_name)
        return EISCP::Message.new(command, value)
      rescue
        return nil
      end
    end

    # Generate individual commands defined by ranges (eg. master-volume 1 - 80)
    def self.create_range_commands(zone, command, value)
      case value.count
      when 3
        range = Range.new(value[0], value[2])
      when 2
        range = Range.new(*value)
      end
      tmp = {}
      range.each do |number|
        #  @yaml_update[zone][command]['values'][number.to_s(16).upcase] 
        tmp.merge! ({ number.to_s(16).rjust(2, "0").upcase => {
          "name" => number.to_s,
          "description" => @yaml_object[zone][command]['values'][value]['description'],
          "models" => @yaml_object[zone][command]['values'][value]['models'],
        }})
      end
      return tmp
    end

    # Generate individual treble and bass commands defined by an array
    def self.create_treble_bass_commands(zone, command, value)
      tmp = {}
      ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
        tmp.merge!({ (value[0] + v.to_s) => {
          "name" => value[0].downcase + v,
          "description" => @yaml_object[zone][command]['values'][value[0] + '{xx}']['description'],
          "models" => @yaml_object[zone][command]['values'][value[0] + '{xx}']['models']
        }})
      end
      return tmp
    end

    # Generate individual balacne commands defined by an array.
    def self.create_balance_commands(zone, command, value)
      tmp = {}
      ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
        tmp.merge!({ v.to_s => {
          "name" => v.downcase,
          "description" => @yaml_object[zone][command]['values']['{xx}']['description'],
          "models" => @yaml_object[zone][command]['values']['{xx}']['models']
        }})
      end
      return tmp
    end


    # Finds variable command values in yaml file (like volume) and makes
    # explicit entries in the command structure hash (@yaml_object)
    #
    @additions = []
    @yaml_object.each_key do |zone|
      @yaml_object[zone].each do |command|
        command = command[0]
        @yaml_object[zone][command]['values'].each do |value|
          value = value[0]
          if value.is_a? Array
            @additions << [zone, command, value, create_range_commands(zone, command, value)]
          elsif value.match(/^(B|T){xx}$/)
            @additions << [zone, command, value, create_treble_bass_commands(zone, command, value)]
          elsif value.match(/^{xx}$/)
            @additions << [zone, command, value, create_balance_commands(zone, command, value)]
          else
            next
          end
        end
      end
    end
    @additions.each do |zone, command, value, hash|
      begin
        @yaml_object[zone][command]['values'].merge! hash
      rescue
        puts "Failed to add #{hash} to #{zone}:#{command}:#{value}"
      end
    end

  end
end
