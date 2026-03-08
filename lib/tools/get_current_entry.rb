# frozen_string_literal: true

require "mcp"

class GetCurrentEntry < MCP::Tool
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

      MCP::Tool::Response.new([{ type: "text", text: format_entry(entry) }])
    end

    private

    def format_entry(entry)
      lines = []
      lines << "Description: #{entry["description"] || "(no description)"}"
      lines << "Project ID: #{entry["project_id"]}" if entry["project_id"]
      lines << "Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?
      lines << "Start: #{entry["start"]}"

      if entry["duration"] && entry["duration"] >= 0
        lines << "Duration: #{format_duration(entry["duration"])}"
      else
        elapsed = Time.now.to_i - Time.parse(entry["start"]).to_i
        lines << "Running for: #{format_duration(elapsed)}"
      end

      lines << "Entry ID: #{entry["id"]}"
      lines.join("\n")
    end

    def format_duration(seconds)
      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      secs = seconds % 60
      format("%<h>d:%<m>02d:%<s>02d", h: hours, m: minutes, s: secs)
    end
  end
end
