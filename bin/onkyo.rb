#!/usr/bin/env ruby

require 'eiscp'
require 'optparse'
require 'ostruct'

# This object parses ARGV and returns an @option hash
#
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

      opts.on '-m', '--monitor', 'Connect to the first discovered reciever and monitor updates' do |m|
        @options.monitor = m 
      end

    end

    options.parse!(args)

    if @options.nil? && ARGV == [] then puts options end

    if @options.discover
      EISCP::Receiver.discover.each {|rec| puts "#{rec.host}:#{rec.port} - #{rec.model} - #{rec.mac_address}"}
      exit 0
    end

    if @options.help
      puts options
      exit 0
    end

    if @options.monitor
      begin
        rec = EISCP::Receiver.new do |reply| 
          puts "#{Time.now} #{rec.host} "\
               "#{reply.zone}: "\
               "#{reply.command_description || reply.command} "\
               "-> #{reply.value_description || reply.value}"
        end
        rec.thread.join
      rescue Interrupt
        fail 'Exiting...'
      rescue Exception => e
        puts "bummer..."
        puts e
      end
    end

    if @options.list_all
      EISCP::Dictionary.zones.each do |zone|
        EISCP::Dictionary.commands[zone].each do |command, command_hash|
          puts "Command - Description"
          puts "\n"
          puts "  '#{Dictionary.name_from_command(command)}' - "\
            "#{Dictionary.description_from_command(command)}"
          puts "\n"
          puts "    Value - Description>"
          puts "\n"
          command_hash[:values].each do |value, attr_hash| 
            puts "      '#{attr_hash[:name]}' - "\
              " #{attr_hash[:description]}"
          end
          puts "\n"
        end
      end
      exit 0
    end

    if ARGV == []
      puts options
      exit 0
    end
  end
end

include EISCP

@options = Options.parse(ARGV)

receiver = EISCP::Receiver.discover[0]
receiver.connect
begin
  command = EISCP::Parser.parse(ARGV.join(' '))
rescue
  raise "Couldn't parse command"
end
reply = receiver.send_recv(command)
puts "#{Time.now}: Response from #{receiver.host}: #{reply.zone.capitalize}   #{reply.command_description || reply.command} -> #{reply.value_description || reply.value}"
