require_relative "../lib/eiscp/command.rb"
require "test/unit"

class TestCommand < Test::Unit::TestCase

  def test_command_to_name
    assert_equal(Command.command_to_name("PWR"), "system-power")
  end

  def test_command_name_to_command
    assert_equal(Command.command_name_to_command("system-power"), "PWR")
  end

  def test_command_value_to_value_name
    assert_equal(Command.command_value_to_value_name("PWR", "01"), "on")
  end

  def test_command_value_name_to_value
    assert_equal(Command.command_value_name_to_value("PWR", "on"), "01")
  end

  def test_description_from_command_name
    assert_equal(Command.description_from_command_name("system-power"), "System Power Command")
  end

  def test_description_from_command
    assert_equal(Command.description_from_command("PWR"), "System Power Command")
  end

end
