class ISCPMessage

  attr_accessor :start
  attr_accessor :unit_type
  attr_accessor :command
  attr_accessor :parameter

  def initialize(command, parameter, unit_type = "1", start = "!")
    @unit_type = unit_type
    @start = start
    @command = command
    @parameter = parameter
  end

  def self.parse(msg_string)
    match = msg_string.match(/(?<start>!)(?<unit_type>\w)(?<command>[A-Z]{3})(?<parameter>\S+)/)
    ISCPMessage.new(match[:command], match[:parameter], match[:unit_type], match[:start])
  end

  def to_s
    return "#{@start + @unit_type + @command + @parameter}\r"
  end

end
