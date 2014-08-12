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
  end

  def test_command_name_to_command
    assert_equal(EISCP::Dictionary.command_name_to_command('system-power'), 'PWR')
  end

  def test_command_value_to_value_name
    assert_equal(EISCP::Dictionary.command_value_to_value_name('PWR', '01'), 'on')
  end

  def test_command_value_name_to_value
    assert_equal(EISCP::Dictionary.command_value_name_to_value('PWR', 'on'), '01')
  end

  def test_description_from_command_name
    assert_equal(EISCP::Dictionary.description_from_command_name('system-power', 'main'), 'System Power Command')
  end

  def test_description_from_command
    assert_equal(EISCP::Dictionary.description_from_command('PWR'), 'System Power Command')
  end

end
