class ISCPMessage

  attr_accessor :start_character
  attr_accessor :unit_type
  attr_accessor :message
  attr_accessor :command
  attr_accessor :parameter

  def initialize(command, parameter, start_character = "!", unit_type = 1)
    @command = command
    @parameter = parameter
    @unit_type = unit_type
    @message = "#{start_character + unit_type + command + parameter}\r"
  end

  def  self.parse(msg_string)
    match = msg_string.match(/(?<start_character>!)(?<unit_type>\w)(?<command>[A-Z]{3})(?<parameter>\S+)/)
    ISCPMessage.new(match[:command], match[:parameter], match[:start_character], match[:unit_type])
  end

end
