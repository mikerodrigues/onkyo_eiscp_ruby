# frozen_string_literal: true

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
          @commands[zone][command][:name]
        rescue StandardError
          nil
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
          nil

        else

          @commands[command_zone].each_pair do |command, attrs|
            return command if attrs[:name] == name
          end
          nil

        end
      end

      # Return a value name from a command and a value
      def command_value_to_value_name(command, value)
        zone = zone_from_command(command)
        command_value = @commands[zone][command][:values][value][:name]
        if command_value.class == String
          command_value
        elsif command_value.class == Array
          command_value.first
        end
      rescue StandardError
        nil
      end

      # Return a value from a command and value name
      def command_value_name_to_value(command, value_name)
        zone = zone_from_command(command)
        @commands[zone][command][:values].each_pair do |k, v|
          if v[:name].class == String
            return k if v[:name] == value_name.to_s
          elsif v[:name].class == Array
            return k if v[:name].first == value_name.to_s
          end
        end
        return nil
      rescue StandardError
        nil
      end

      # Return a command description from a command name and zone
      def description_from_command_name(name, zone)
        @commands[zone].each_pair do |command, attrs|
          return @commands[zone][command][:description] if attrs[:name] == name
        end
        nil
      end

      # Return a command description from a command
      def description_from_command(command)
        zone = zone_from_command(command)
        @commands[zone][command][:description]
      end

      # Return a value description from a command and value
      def description_from_command_value(command, value)
        zone = zone_from_command(command)
        @commands[zone][command][:values].select do |k, v|
          return v[:description] if k == value
        end
        nil
      end

      # Return a list of commands compatible with a given model
      def list_compatible_commands(modelstring)
        sets = []
        @modelsets.each_pair do |set, array|
          sets << set if array.include? modelstring
        end
        sets
      end

      # Checks to see if the command is in the Dictionary
      #
      def known_command?(command)
        zone = zone_from_command(command)
        @commands[zone].include? command
      rescue StandardError
        nil
      end
    end
  end
end
