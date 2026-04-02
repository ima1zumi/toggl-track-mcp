# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Tools
    class GetProjects < MCP::Tool
      tool_name "get_projects"
      title "Get Projects"
      description "Get all projects in the workspace"

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: true,
      )

      input_schema(properties: {})

      class << self
        def call(server_context: nil)
          client = server_context[:client]
          projects = client.projects

          if projects.nil? || projects.empty?
            return MCP::Tool::Response.new([MCP::Content::Text.new("No projects found.")])
          end

          lines = projects.select { |p| p["active"] }.map do |project|
            <<~TEXT.gsub(/^\s*\n/, "").chomp
                Name: #{project["name"]}
                ID: #{project["id"]}
              #{"  Color: #{project["color"]}" if project["color"]}
            TEXT
          end

          text = <<~TEXT.chomp
            Projects (#{lines.size}):

            #{lines.join("\n\n")}
          TEXT

          MCP::Tool::Response.new([MCP::Content::Text.new(text)])
        end
      end
    end
  end
end
