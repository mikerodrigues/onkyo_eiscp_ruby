require_relative '../lib/eiscp/dictionary.rb'
require 'minitest/autorun'

class TestDictionary < MiniTest::Test
  def test_zone_from_command
    assert_equal(EISCP::Dictionary.zone_from_command('PWR'), 'main')
    assert_equal(EISCP::Dictionary.zone_from_command('ZPW'), 'zone2')
    assert_equal(EISCP::Dictionary.zone_from_command('CDS'), 'dock')
  end

  def test_command_to_name
    assert_equal(EISCP::Dictionary.command_to_name('PWR'), 'system-power')
    assert_equal(EISCP::Dictionary.command_to_name('ZPW'), 'power')
    assert_equal(EISCP::Dictionary.command_to_name('PW3'), 'power')
    assert_equal(EISCP::Dictionary.command_to_name('PW4'), 'power')
  end

  def test_command_name_to_command
    assert_equal(EISCP::Dictionary.command_name_to_command('system-power'), 'PWR')
    assert_equal(EISCP::Dictionary.command_name_to_command('master-volume'), 'MVL')
    assert_equal(EISCP::Dictionary.command_name_to_command('power'), 'ZPW')
  end

  def test_command_value_to_value_name
    assert_equal(EISCP::Dictionary.command_value_to_value_name('PWR', '01'), 'on')
    assert_equal(EISCP::Dictionary.command_value_to_value_name('PWR', 'QSTN'), 'query')
  end

  def test_command_value_name_to_value
    assert_equal(EISCP::Dictionary.command_value_name_to_value('PWR', 'on'), '01')
    assert_equal(EISCP::Dictionary.command_value_name_to_value('ZPW', 'on'), '01')
  end

  def test_description_from_command_name
    assert_equal(EISCP::Dictionary.description_from_command_name('system-power', 'main'), 'System Power Command')
    assert_equal(EISCP::Dictionary.description_from_command_name('power', 'zone2'), 'Zone2 Power Command')
  end

  def test_description_from_command
    assert_equal(EISCP::Dictionary.description_from_command('PWR'), 'System Power Command')
    assert_equal(EISCP::Dictionary.description_from_command('ZPW'), 'Zone2 Power Command')
  end
end
