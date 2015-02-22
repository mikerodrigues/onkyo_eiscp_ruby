require 'rake/testtask'
require 'bundler'
require_relative './lib/eiscp'

task :build do
  begin
    puts 'building gem...'
    `gem build onkyo_eiscp_ruby.gemspec`
  rescue
    puts 'build failed.'
  end
end

task :install do
  begin
    puts 'installing gem...'
    `gem install onkyo_eiscp_ruby-#{EISCP::VERSION}.gem`
  rescue
    puts 'install failed.'
  end
end

task :console do
  require 'rubygems'
  require 'pry'
  ARGV.clear
  PRY.start
end

task :default => ['build', 'install']

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/tc*.rb']
  t.verbose = true
end
