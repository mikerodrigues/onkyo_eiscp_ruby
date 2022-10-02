# frozen_string_literal: true

module EISCP
  module Parser
    # This module parses an ISCP string and returns a Message object
    #
    module ISCPParser
      # Regexp for parsing ISCP messages
      REGEX = /(?<start>!)?(?<unit_type>(?:\d|x))?(?<command>[A-Z]{3})\s?(?<value>.*?)(?<terminator>[[:cntrl:]]*$)/
      def self.parse(string)
        match = string.match(REGEX)

        # Convert MatchData to Hash
        hash = Hash[match.names.zip(match.captures)]

        # Remove nil and blank values
        hash.delete_if { |_, v| v.nil? || v == '' }

        # Convert keys to symbols
        hash = hash.transform_keys(&:to_sym)

        if value == nil
          raise "Could not find a value in #{string}"
        end
        Message.new(**hash)
      end
    end
  end
end
