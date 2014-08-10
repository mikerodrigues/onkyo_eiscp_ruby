require_relative './dictionary_generators'

module EISCP
  module Dictionary

    extend DictionaryGenerators

    class << self
      attr_reader :zones
      attr_reader :modelsets
      attr_reader :commands
    end

    DEFAULT_ZONE = 'main'
    @yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
    @commands = YAML.load(File.read(@yaml_file_path))
    @modelsets = @commands["modelsets"]
    @commands.delete("modelsets")
    @zones = @commands.map{|k, v| k}



    # Return the zone that includes the given command
    def self.zone_from_command(command)
      @zones.each do |zone|
        @commands[zone].each_pair do |k, v|
          if command == k
            return zone
          end
        end
      end
      return nil
    end

    # Return the human readable name of a command
    def self.command_to_name(command)
      command = command.upcase
      begin
        zone = zone_from_command(command)
        return @commands[zone][command]['name']
      rescue
        return nil
      end
    end

    # Return the command from a given command name
    def self.command_name_to_command(name)
      @zones.each do |zone|
        @commands[zone].each_pair do |command, attrs|
          if attrs['name'] == name
            return command
          end
        end
        return nil
      end
    end

    # Return a command value name from a command and value
    def self.command_value_to_value_name(command, value)
      begin
        zone = zone_from_command(command)
        return @commands[zone][command]['values'][value]['name'] 
      rescue
        return nil
      end
    end

    # Return a command value from a command and value name
    def self.command_value_name_to_value(command, value_name)
      zone = zone_from_command(command)
      @commands[zone][command]['values'].each_pair do |k, v|
        if v['name'] == value_name.to_s
          return k
        end
      end
      return nil
    end

    # Return a description form a command name and zone
    def self.description_from_command_name(name, zone)
      @commands[zone].each_pair do |command, attrs|
        if attrs['name'] == name
          return @commands[zone][command]['description']
        end
      end
      return nil
    end

    # Return a description from a command
    def self.description_from_command(command)
      begin
        zone = zone_from_command(command)
        return @commands[zone][command]['description']
      rescue
        return nil
      end
    end

    # Return a description from a command and value
    def self.description_from_command_value(command, value)
      zone = zone_from_command(command)
      return @commands[zone][command]['values'].select do |k, v| 
        if k == value
          return v['description']
        end
      end
      return nil
    end

    def self.validate_command(command)
      (command_to_name(command) || command_name_to_command(command)) ? true : false
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

    # Finds variable command values in yaml file (like volume) and makes
    # explicit entries in the command structure hash (@commands)
    #   
    @additions = []
    @commands.each_key do |zone|
      @commands[zone].each do |command|
        command = command[0]
        @commands[zone][command]['values'].each do |value|
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
        @commands[zone][command]['values'].merge! hash
      rescue
        puts "Failed to add #{hash} to #{zone}:#{command}:#{value}"
      end 
    end 

  end
end

