# frozen_string_literal: true

require_relative "lib/toggl_track_mcp/version"

Gem::Specification.new do |spec|
  spec.name = "toggl_track_mcp"
  spec.version = TogglTrackMcp::VERSION
  spec.authors = ["ima1zumi"]
  spec.license = "MIT"

  spec.summary = "An MCP server for Toggl Track"
  spec.description = "A Model Context Protocol (MCP) server that provides tools to interact with Toggl Track time tracking API."
  spec.homepage = "https://github.com/ima1zumi/toggl-track-mcp"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[test/ spec/ .git .env])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mcp", ">= 0.10.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
