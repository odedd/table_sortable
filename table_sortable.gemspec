# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "table_sortable/version"

Gem::Specification.new do |spec|
  spec.name          = "table_sortable"
  spec.version       = TableSortable::VERSION
  spec.authors       = ["Oded Davidov"]
  spec.email         = ["davidovoded@gmail.com"]

  spec.summary       = 'Use jquery-tablesorter.js with server side filtering, pagination and sorting'
  spec.description   = 'Use jquery-tablesorter.js with server side filtering, pagination and sorting'
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "localhost"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_dependency "kaminari", '~> 0.17.0'
  spec.add_dependency "rails", '~> 5.1', '>= 5.1.1'
end
