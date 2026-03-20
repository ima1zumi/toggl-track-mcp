# frozen_string_literal: true

require "mcp"
require_relative "../duration_formatter"

class GetTodayEntries < MCP::Tool
  extend DurationFormatter

  description "Get all time entries for today"

  annotations(
    read_only_hint: true,
    destructive_hint: false,
  )

  input_schema(properties: {})

  class << self
    def call(server_context: nil)
      client = server_context[:client]
      entries = client.today_entries

      if entries.nil? || entries.empty?
        return MCP::Tool::Response.new([{ type: "text", text: "No time entries for today." }])
      end

      tz = client.tz
      total_seconds = 0
      lines = entries.map do |entry|
        duration = entry["duration"]
        if duration >= 0
          total_seconds += duration
        else
          duration = Time.now.to_i - Time.parse(entry["start"]).to_i
          total_seconds += duration
        end

        parts = []
        parts << "  Description: #{entry["description"] || "(no description)"}"
        if entry["project_id"]
          name = client.project_name(entry["project_id"])
          parts << "  Project: #{name}" if name
          parts << "  Project ID: #{entry["project_id"]}"
        end
        parts << "  Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?
        parts << "  Start: #{format_time(entry["start"], tz: tz)}"
        parts << "  Stop: #{format_time(entry["stop"], tz: tz)}" if entry["stop"]
        parts << "  Duration: #{format_duration_human(duration)}"
        parts << "  Running" if entry["duration"] < 0
        parts << "  Entry ID: #{entry["id"]}"
        parts.join("\n")
      end

      text = "Today's entries (#{entries.size} total, #{format_duration_human(total_seconds)}):\n\n"
      text += lines.join("\n\n")

      MCP::Tool::Response.new([{ type: "text", text: text }])
    end
  end
end
