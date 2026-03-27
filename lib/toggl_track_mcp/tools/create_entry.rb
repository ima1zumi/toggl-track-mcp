# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Tools
    class CreateEntry < MCP::Tool
      description "Create a new time entry. By default starts a running timer."

      input_schema(
        properties: {
          description: {
            type: "string",
            description: "What you are working on",
          },
          project_id: {
            type: "integer",
            description: "Project ID to associate with (use get_projects to find IDs)",
          },
          tags: {
            type: "array",
            items: { type: "string" },
            description: "Tags for the entry (auto-created if they don't exist)",
          },
          start: {
            type: "string",
            description: "Start time in UTC (e.g. 2026-03-08T09:00:00Z). Defaults to now.",
          },
          duration: {
            type: "integer",
            description: "Duration in seconds. Use -1 to start a running timer (default). Use positive value for a completed entry.",
          },
        },
        required: ["description"],
      )

      class << self
        def call(description:, project_id: nil, tags: nil, start: nil, duration: -1, server_context: nil)
          client = server_context[:client]

          entry = client.create_entry(
            description: description,
            project_id: project_id,
            tags: tags,
            start: start,
            duration: duration,
          )

          status = duration == -1 ? "Timer started" : "Entry created"
          text = <<~TEXT.gsub(/^\s*\n/, "").chomp
            #{status}:
              Description: #{entry["description"]}
            #{"  Project ID: #{entry["project_id"]}" if entry["project_id"]}
            #{"  Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?}
              Start: #{entry["start"]}
              Entry ID: #{entry["id"]}
          TEXT

          MCP::Tool::Response.new([{ type: "text", text: text }])
        end
      end
    end
  end
end
