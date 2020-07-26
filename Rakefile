# frozen_string_literal: true

require 'rake/testtask'
require 'bundler'
require_relative './lib/eiscp'

task :build do
  puts 'building gem...'
  `gem build onkyo_eiscp_ruby.gemspec`
rescue StandardError
  puts 'build failed.'
end

task :install do
  puts 'installing gem...'
  `gem install onkyo_eiscp_ruby-#{EISCP::VERSION}.gem`
rescue StandardError
  puts 'install failed.'
end

task :console do
  require 'rubygems'
  require 'pry'
  ARGV.clear
  PRY.start
end

task default: %w[build install]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/tc*.rb']
  t.verbose = true
end
