require 'yaml'

module EISCP
  module Dictionary

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
          "description" => @commands[zone][command]['values'][value]['description'],
          "models" => @commands[zone][command]['values'][value]['models'],
        }})
      end
      return tmp
    end

    def self.create_treble_bass_commands(zone, command, value)
      tmp = {}
      ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
        tmp.merge!({ (value[0] + v.to_s) => {
          "name" => value[0].downcase + v,
          "description" => @commands[zone][command]['values'][value[0] + '{xx}']['description'],
          "models" => @commands[zone][command]['values'][value[0] + '{xx}']['models']
        }})
      end
      return tmp
    end

    def self.create_balance_commands(zone, command, value)
      tmp = {}
      ['-A', '-8', '-6', '-4', '-2', '00', '+2', '+4', '+6', '+8', '+A'].each do |v|
        tmp.merge!({ v.to_s => {
          "name" => v.downcase,
          "description" => @commands[zone][command]['values']['{xx}']['description'],
          "models" => @commands[zone][command]['values']['{xx}']['models']
        }})
      end
      return tmp
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
