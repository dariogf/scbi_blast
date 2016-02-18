# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scbi_blast/version'

Gem::Specification.new do |spec|
  spec.name          = "scbi_blast"
  spec.version       = ScbiBlast::VERSION
  spec.authors       = ["dariogf"]
  spec.email         = ["dariogf@gmail.com"]

  spec.summary       = %q{ruby gem to handle blast+ executions using pipes when possible to read data without the need of temporary files.}
  spec.description   = %q{scbi_blast can handle *blastn*, *blastp* and *dustmasker* applications from NCBI blast package. 
Input sequences can be supplied as an array (see the example below) or as a chunk of text 
inside a string variable.}
  spec.homepage      = "http://www.scbi.uma.es"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"

  spec.add_runtime_dependency 'xml-simple','>= 1.0.12'
end
