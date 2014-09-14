require 'yaml'

module EISCP
  module Dictionary
    # This module provides methods that can be used to generate command entries
    # that are specified as ranges in the yaml file.
    #
    module DictionaryGenerators
      # Creates a hash object for range commands like master-volume
      #
      def create_range_commands(zone, command, value)
        case value.count
        when 3
          range = Range.new(value[0], value[2])
        when 2
          range = Range.new(*value)
        end
        tmp = {}
        range.each do |number|
          tmp.merge!(number.to_s(16).rjust(2, '0').upcase =>
            {
              :name => number.to_s,
              :description =>
                @commands[zone][command][:values][value][:description].gsub(/\d - \d+/, number.to_s),
              :models => @commands[zone][command][:values][value][:models]
            }
          )
        end
        return tmp
      end

      # Creates hash object for treble and bass commands
      #
      def create_treble_bass_commands(zone, command, value)
        tmp = {}
        ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
          tmp.merge!((value[0] + v.to_s) =>
            {
              :name => value[0].downcase + v,
              :description =>
                @commands[zone][command][:values][value[0] + '{xx}'][:description].gsub(/\(.*[\]|\)]$/, v),
              :models => @commands[zone][command][:values][value[0] + '{xx}'][:models]
            }
          )
        end
        return tmp
      end

      # Creates hash object for balance commands
      #
      def create_balance_commands(zone, command, _value)
        tmp = {}
        ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
          tmp.merge!(v.to_s =>
            {
              :name => v.downcase,
              :description =>
                @commands[zone][command][:values]['{xx}'][:description].gsub(/\(.*[\]|\)]$/, v),
              :models => @commands[zone][command][:values]['{xx}'][:models]
            }
          )
        end
        return tmp
      end
    end
  end
end
