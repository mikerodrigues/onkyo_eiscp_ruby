require_relative "../lib/eiscp/iscp_message.rb"
require "test/unit"

class TestISCPMessage <  Test::Unit::TestCase

  def test_create_discovery_iscp_message
    assert_equal(ISCPMessage.new("ECN", "QSTN", "x", "!").to_s, "!xECNQSTN\r")
  end

  def test_parse_discovery_iscp_message
    assert_equal(ISCPMessage.parse("!xECNQSTN\r").to_s, "!xECNQSTN\r")
  end

end
