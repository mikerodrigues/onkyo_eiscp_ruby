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

      opts.on '-c', '--connect', 'Connect to the first discovered reciever and show updates' do |c|
        @options.connect = c
      end

    end

    options.parse!(args)

    if @options == nil && ARGV == []
      puts options
    end

    if @options.discover
      EISCP::Receiver.discover.each do |receiver|
        puts  EISCP::Message.parse(receiver[0]).to_iscp
      end
      exit 0
    end

    if @options.help
      puts options
      exit 0 
    end

    if @options.connect
      eiscp = EISCP::Receiver.new(EISCP::Receiver.discover[0][1])
      eiscp.connect do |data|
        puts msg = EISCP::Receiver.parse(data).to_iscp
      end
    end

    if ARGV == []
      puts options
      exit 0
    end
  end

end


@options = Options.parse(ARGV)


receiver = EISCP::Receiver.new(EISCP::Receiver.discover[0][1])
message = (EISCP::Message.parse(ARGV.join(" ")).to_eiscp)
puts receiver.send_recv message




