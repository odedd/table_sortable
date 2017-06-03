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
  spec.description   = "TableSortable adds multi-column, server-side filtering, sorting and pagination to the tableSorter jQuery plugin, so you don't have to worry about interpreting the query parameters, combining multiple queries, columns to sort by, or figuring out how to send the correct page back to the client. It is a Rails backend complementation to the frontend tableSorter.js."
  spec.homepage      = 'https://github.com/odedd/table_sortable'
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
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "factory_girl_rails", "~> 4.8"
  spec.add_development_dependency "activerecord", '~> 5.1', '>= 5.1.1'
  spec.add_dependency "railties", '~> 5.1', '>= 5.1.1'
  # spec.add_dependency "activesupport", '~> 5.1', '>= 5.1.1'
end
