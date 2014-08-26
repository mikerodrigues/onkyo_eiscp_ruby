require_relative './parser/eiscp_parser'
require_relative './parser/iscp_parser'
require_relative './parser/human_readable_parser'

module EISCP
  module Parser
    def self.parse(string)
      case string
      when /^ISCP/
        EISCPParser.parse(string)
      when ISCPParser::REGEX
        ISCPParser.parse(string)
      else
        HumanReadableParser.parse(string)
      end
    end 
  end
end
