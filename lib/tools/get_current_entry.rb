# frozen_string_literal: true

require "mcp"
require_relative "../duration_formatter"

class GetCurrentEntry < MCP::Tool
  extend DurationFormatter

  description "Get the currently running time entry"

  annotations(
    read_only_hint: true,
    destructive_hint: false,
  )

  input_schema(properties: {})

  class << self
    def call(server_context: nil)
      client = server_context[:client]
      entry = client.current_entry

      if entry.nil?
        return MCP::Tool::Response.new([{ type: "text", text: "No timer is currently running." }])
      end

      MCP::Tool::Response.new([{ type: "text", text: format_entry(entry, client) }])
    end

    private

    def format_entry(entry, client)
      tz = client.tz
      lines = []
      lines << "Description: #{entry["description"] || "(no description)"}"
      if entry["project_id"]
        name = client.project_name(entry["project_id"])
        lines << "Project: #{name}" if name
        lines << "Project ID: #{entry["project_id"]}"
      end
      lines << "Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?

      start_time = Time.parse(entry["start"])
      elapsed = Time.now.to_i - start_time.to_i
      lines << "Start: #{start_time.getlocal(tz).strftime("%H:%M")} (#{format_duration_human(elapsed)} elapsed)"

      lines << "Entry ID: #{entry["id"]}"
      lines.join("\n")
    end
  end
end
