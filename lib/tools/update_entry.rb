# frozen_string_literal: true

require "mcp"

class UpdateEntry < MCP::Tool
  description "Update an existing time entry"

  input_schema(
    properties: {
      time_entry_id: {
        type: "integer",
        description: "The ID of the time entry to update",
      },
      description: {
        type: "string",
        description: "New description",
      },
      project_id: {
        type: "integer",
        description: "New project ID",
      },
      tags: {
        type: "array",
        items: { type: "string" },
        description: "New tags (replaces existing tags)",
      },
      start: {
        type: "string",
        description: "New start time in ISO 8601 format (e.g. 2026-03-08T09:00:00Z)",
      },
      stop: {
        type: "string",
        description: "New stop time in ISO 8601 format (e.g. 2026-03-08T10:30:00Z)",
      },
    },
    required: ["time_entry_id"],
  )

  class << self
    def call(time_entry_id:, description: nil, project_id: nil, tags: nil, start: nil, stop: nil, server_context: nil)
      client = server_context[:client]

      params = {}
      params[:description] = description unless description.nil?
      params[:project_id] = project_id unless project_id.nil?
      params[:tags] = tags unless tags.nil?
      params[:start] = start unless start.nil?
      params[:stop] = stop unless stop.nil?

      if params.empty?
        return MCP::Tool::Response.new(
          [{ type: "text", text: "No fields to update. Provide at least one of: description, project_id, tags, start, stop." }],
          error: true,
        )
      end

      entry = client.update_entry(time_entry_id: time_entry_id, **params)

      text = "Entry updated:\n"
      text += "  Description: #{entry["description"] || "(no description)"}\n"
      text += "  Project ID: #{entry["project_id"]}\n" if entry["project_id"]
      text += "  Tags: #{entry["tags"].join(", ")}\n" if entry["tags"]&.any?
      text += "  Start: #{entry["start"]}\n" if entry["start"]
      text += "  Stop: #{entry["stop"]}\n" if entry["stop"]
      text += "  Entry ID: #{entry["id"]}"

      MCP::Tool::Response.new([{ type: "text", text: text }])
    end
  end
end
