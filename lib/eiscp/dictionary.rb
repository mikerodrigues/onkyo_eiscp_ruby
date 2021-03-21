# frozen_string_literal: true

require_relative './dictionary/dictionary_generators'
require_relative './dictionary/dictionary_helpers'

module EISCP
  # This module provides an interface to the information from the yaml file. It
  # uses DictionaryGenerators to add commands specified by ranges in the yaml
  # file. It uses DictionaryHelpers to convert commands and values to and from
  # their human readable form.
  #
  module Dictionary
    extend DictionaryGenerators
    extend DictionaryHelpers

    class << self
      attr_reader :zones
      attr_reader :modelsets
      attr_reader :commands
    end

    DEFAULT_ZONE = 'main'
    @yaml_file_path = File.join(__dir__, '../../eiscp-commands.yaml')
    @commands = YAML.load(File.read(@yaml_file_path))
    @modelsets = @commands[:modelsets]
    @commands.delete(:modelsets)
    @zones = @commands.map { |k, _| k }

    @additions = []
    @commands.each_key do |zone|
      @commands[zone].each do |command|
        command = command[0]
        @commands[zone][command][:values].each do |value|
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
      @commands[zone][command][:values].merge! hash
    rescue StandardError
      puts "Failed to add #{hash} to #{zone}:#{command}:#{value}"
    end
  end
end
