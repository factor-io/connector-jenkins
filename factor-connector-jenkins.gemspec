# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-jenkins'
  s.version       = '0.0.3'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Jenkins Factor.io Connector'
  s.files         = Dir.glob('lib/factor/connector/*.rb')
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'jenkins_api_client', '~> 1.3.0'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.7'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end