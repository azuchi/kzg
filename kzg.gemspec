# frozen_string_literal: true

require_relative 'lib/kzg/version'

Gem::Specification.new do |spec|
  spec.name          = 'kzg'
  spec.version       = KZG::VERSION
  spec.authors       = ['azuchi']
  spec.email         = ['azuchi@chaintope.com']

  spec.summary       = 'KZG polynomial commitment library for Ruby.'
  spec.description   = 'KZG polynomial commitment library for Ruby.'
  spec.homepage      = 'https://github.com/azuchi/kzg'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'bigdecimal'
  spec.add_dependency 'bls12-381', '~> 0.3.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency 'bundler'
end
