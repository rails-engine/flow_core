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
  spec.summary     = "FlowCore is a Rails engine to help you build your automation or business process application."
  spec.description = "A multi purpose, extendable, Workflow-net-based workflow engine for Rails applications, focusing on workflow definition and scheduling."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.5.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "acts_as_list", "~> 1.2.2"
  spec.add_dependency "ancestry", "~> 4.3.3"
  spec.add_dependency "rails", "~> 7.2.1"
  spec.add_dependency "rgl", "~> 0.6.6"
end
