# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "flow_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "flow_core"
  spec.version     = FlowCore::VERSION
  spec.authors     = ["jasl"]
  spec.email       = ["jasl9187@hotmail.com"]
  spec.homepage    = "https://github.com/rails-engine/flow_core"
  spec.summary     = "A multi purpose, extendable, Workflow-net-based workflow engine for Rails applications"
  spec.description = "A multi purpose, extendable, Workflow-net-based workflow engine for Rails applications, focusing on workflow definition and scheduling."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.5.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0"
  spec.add_dependency "rgl", "~> 0.5"

  spec.add_development_dependency "sqlite3", "~> 1.4"
end
