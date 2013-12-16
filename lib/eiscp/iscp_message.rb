class ISCPMessage

  attr_accessor :message

  def initialize(command, parameter)
    @command = command
    @parameter = parameter
    @message = "!1#{command + parameter}\r"
  end

end
