# frozen_string_literal: true

require "mcp"

class GetProjects < MCP::Tool
  description "Get all projects in the workspace"

  annotations(
    read_only_hint: true,
    destructive_hint: false,
  )

  input_schema(properties: {})

  class << self
    def call(server_context: nil)
      client = server_context[:client]
      projects = client.projects

      if projects.nil? || projects.empty?
        return MCP::Tool::Response.new([{ type: "text", text: "No projects found." }])
      end

      lines = projects.select { |p| p["active"] }.map do |project|
        parts = []
        parts << "  Name: #{project["name"]}"
        parts << "  ID: #{project["id"]}"
        parts << "  Color: #{project["color"]}" if project["color"]
        parts.join("\n")
      end

      text = "Projects (#{lines.size}):\n\n"
      text += lines.join("\n\n")

      MCP::Tool::Response.new([{ type: "text", text: text }])
    end
  end
end
