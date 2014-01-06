require_relative "../lib/eiscp/iscp_message.rb"
require "test/unit"

class TestISCPMessage <  Test::Unit::TestCase

  
  DISCOVERY_PACKET = ISCPMessage.new('ECN', 'QSTN', 'x', '!')
  DISCOVERY_STRING = DISCOVERY_PACKET.to_eiscp


  def test_create_discovery_iscp_message
    assert_equal(ISCPMessage.new("ECN", "QSTN", "x", "!").to_iscp, "!xECNQSTN")
  end

  def test_parse_discovery_iscp_message
    assert_equal(ISCPMessage.parse("!xECNQSTN").to_iscp, "!xECNQSTN")
  end

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.to_eiscp, DISCOVERY_STRING)
  end

  def test_parse_discovery_packet_string
    assert_equal(ISCPMessage.parse(DISCOVERY_STRING).to_eiscp, DISCOVERY_PACKET.to_eiscp)
  end

end
