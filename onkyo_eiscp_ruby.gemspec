Gem::Specification.new do |s|
  s.name         = 'onkyo_eiscp_ruby'
  s.version      = File.read(File.expand_path('VERSION', File.dirname(__FILE__))).strip
  s.licenses      = ['MIT']
  s.platform     = Gem::Platform::RUBY
  s.summary      = 'Manipulate Onkyo stereos with the eISCP protocol'
  s.files        = Dir.glob('{bin,config,lib,test,doc}/**/*') +
    ["VERSION", "onkyo_eiscp_ruby.gemspec", "eiscp-commands.yaml"]
  s.extra_rdoc_files = ["README.md"]
  s.require_path = 'lib'

  s.homepage     = "https://github.com/mikerodrigues/onkyo_eiscp_ruby"

  s.description  = %q(
    Control Onkyo receivers over the network.Use the provided binary script or
    require the library for use in your scripts.
  )

  s.author       = "Michael Rodrigues"
  s.email        = "mikebrodrigues@gmail.com"

  s.test_files = Dir[ 'test/tc*.rb' ]
  s.executables = %w(
    onkyo.rb
    onkyo-server.rb
  )

end
