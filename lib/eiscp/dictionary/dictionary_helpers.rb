module EISCP
  module Dictionary
    # This module provides methods to get information from the Dictionary about
    # commands, values, zones, and models.
    #
    module DictionaryHelpers
      # Return the zone that includes the given command
      def zone_from_command(command)
        @zones.each do |zone|
          @commands[zone].each_pair do |k, _|
            return zone if command == k
          end
        end
        nil
      end

      # Return the human readable name of a command
      def command_to_name(command)
        command = command.upcase
        begin
          zone = zone_from_command(command)
          return @commands[zone][command][:name]
        rescue
          return nil
        end
      end

      # Return the command from a given command name
      def command_name_to_command(name, command_zone = nil)
        if command_zone.nil?

          @zones.each do |zone|
            @commands[zone].each_pair do |command, attrs|
              return command if attrs[:name] == name
            end
          end
          return nil

        else

          @commands[command_zone].each_pair do |command, attrs|
            return command if attrs[:name] == name
          end
          return nil

        end
      end

      # Return a command value name from a command and value
      def command_value_to_value_name(command, value)
        begin
        zone = zone_from_command(command)
        @commands[zone][command][:values][value][:name]
        rescue
          nil
        end
      end

      # Return a command value from a command and value name
      def command_value_name_to_value(command, value_name)
        zone = zone_from_command(command)
        @commands[zone][command][:values].each_pair do |k, v|
          return k if v[:name] == value_name.to_s
        end
        nil
      end

      # Return a description form a command name and zone
      def description_from_command_name(name, zone)
        @commands[zone].each_pair do |command, attrs|
          if attrs[:name] == name
            return @commands[zone][command][:description]
          end
        end
        nil
      end

      # Return a description from a command
      def description_from_command(command)
        zone = zone_from_command(command)
        @commands[zone][command][:description]
      end

      # Return a description from a command and value
      def description_from_command_value(command, value)
        zone = zone_from_command(command)
        @commands[zone][command][:values].select do |k, v|
          return v[:description] if k == value
        end
      end

      # Return a list of commands compatible with a given model
      def list_compatible_commands(modelstring)
        sets = []
        @modelsets.each_pair do |set, array|
          sets << set if array.include? modelstring
        end
        sets
      end

      def validate_command(command)
        zone = zone_from_command(command)
        @commands[zone].include? command
      end
    end
  end
end
