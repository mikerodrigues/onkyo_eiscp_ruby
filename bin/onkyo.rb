#!/usr/bin/env ruby

require 'eiscp'
require 'optparse'
require 'ostruct'

class Options
  DEFAULT_OPTIONS = { verbose: true, all: false }
  USAGE = ' Usage: onkyo_rb [options]'

  def self.parse(args)
    @options = OpenStruct.new

    options = OptionParser.new do |opts|

      opts.banner = USAGE

      opts.on '-d', '--discover', 'Find Onkyo Receivers on the local broadcast domain' do |d|
        @options.discover = d
      end

      opts.on '-a', '--all', 'Send command to all Onkyo Receivers instead of just the first one' do |a|
        @options.all = a
      end

      opts.on '-h', '--help', 'Show this message' do |h|
        @options.help = h
      end

      opts.on '-l', '--list', 'List commands compatible for each discovered model' do |l|
        @options.list = l
      end

      opts.on '-L', '--list-all', 'List all commands regardless of model compatibility' do |l|
        @options.list_all = l
      end

    end

    options.parse!(args)

    if @options.discover
      EISCP.discover.each do |receiver|
        puts  EISCPPacket.parse(receiver).packet_string
      end
      exit 0
    end

    if @options.help
      puts options
      exit 0 
    end

  end

end

@options = Options.parse(ARGV)



#command = Command.parse(ARGV)
puts EISCP.discover
eiscp = EISCP.new(EISCP.discover[0][1])
eiscp.send_recv(EISCPPacket.new(ISCPMessage.new(ARGV[0], ARGV[1]).message).packet_string)




