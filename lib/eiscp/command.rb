require_relative './receiver'
require_relative './dictionary'

module EISCP
  module Command

    # Return the zone that includes the given command
    def self.zone_from_command(command)
      Dictionary.zones.each do |zone|
        Dictionary.commands[zone].each_pair do |k, v|
          if command == k
            return zone
          end
        end
      end
      return nil
    end

    # Return the human readable name of a command
    def self.command_to_name(command)
      begin
        zone = zone_from_command(command)
        return Dictionary.commands[zone][command]['name']
      rescue
        return nil
      end
    end

    # Return the command from a given command name
    def self.command_name_to_command(name, zone)
      Dictionary.commands[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return command
        end
      end
      return nil
    end

    # Return a command value name from a command and value
    def self.command_value_to_value_name(command, value)
      begin
        zone = zone_from_command(command)
        return Dictionary.commands[zone][command]['values'][value]['name'] 
      rescue
        return nil
      end
    end

    # Return a command value from a command and value name
    def self.command_value_name_to_value(command, value_name)
      zone = zone_from_command(command)
      Dictionary.commands[zone][command]['values'].each_pair do |k, v|
        if v['name'] == value_name.to_s
          return k
        end
      end
      return nil
    end

    # Return a description form a command name and zone
    def self.description_from_command_name(name, zone)
      Dictionary.commands[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return Dictionary.commands[zone][command]['description']
        end
      end
      return nil
    end

    # Return a description from a command
    def self.description_from_command(command)
      begin
        zone = zone_from_command(command)
        return Dictionary.commands[zone][command]['description']
      rescue
        return nil
      end
    end

    # Return a description from a command and value
    def self.description_from_command_value(command, value)
      zone = zone_from_command(command)
      return Dictionary.commands[zone][command]['values'].select do |k, v| 
        if k == value
          return v['description']
        end
      end
      return nil
    end

    # Return a list of all commands
    def self.list_all_commands
      Dictionary.commands.each_pair do |zone, commands|
        Dictionary.commands[zone].each_pair do |command, attrs|
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
      Dictionary.modelsets.each_pair do |set, array|
        if array.include? modelstring
          sets << set
        end
      end
      return sets
    end

    # Parse a command and return a message object
    def self.parse(string)
      array = string.split(" ")
      zone = Dictionary::DEFAULT_ZONE
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

  end
end

