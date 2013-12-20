require_relative "../lib/eiscp/iscp_message.rb"
require "test/unit"

class TestISCPMessage <  Test::Unit::TestCase

  def test_create_discovery_iscp_message
    assert_equal(ISCPMessage.new("ECN", "QSTN", "!", "x").message, "!xECNQSTN\r")
  end

  def test_parse_discovery_iscp_message
    assert_equal(ISCPMessage.parse("!xECNQSTN\r").message, "!xECNQSTN\r")
  end

end
