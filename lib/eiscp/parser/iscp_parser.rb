require_relative '../message'

module EISCP
  module Parser
    # This module parses an ISCP string and returns a Message object
    #
    module ISCPParser
      # Regexp for parsing ISCP messages
      REGEX = /(?<start>!)?(?<unit_type>(\d|x))?(?<command>[A-Z]{3})\s?(?<value>.*?)(?<terminator>[[:cntrl:]]*$)/
      def self.parse(string)
        match = string.match(REGEX)

        # Convert MatchData to Hash
        hash = Hash[match.names.zip(match.captures)]

        # Remove nil and blank values
        hash.delete_if { |_, v| v.nil? || v == '' }

        # Convert keys to symbols
        hash = hash.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v
          memo
        end

        Message.new(**hash)
      end
    end
  end
end
