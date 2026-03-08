# frozen_string_literal: true

require "mcp"

class GetTodayEntries < MCP::Tool
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
        parts << "  Project ID: #{entry["project_id"]}" if entry["project_id"]
        parts << "  Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?
        parts << "  Start: #{entry["start"]}"
        parts << "  Stop: #{entry["stop"]}" if entry["stop"]
        parts << "  Duration: #{format_duration(duration)}"
        parts << "  Running" if entry["duration"] < 0
        parts << "  Entry ID: #{entry["id"]}"
        parts.join("\n")
      end

      text = "Today's entries (#{entries.size} total, #{format_duration(total_seconds)}):\n\n"
      text += lines.join("\n\n")

      MCP::Tool::Response.new([{ type: "text", text: text }])
    end

    private

    def format_duration(seconds)
      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      secs = seconds % 60
      format("%<h>d:%<m>02d:%<s>02d", h: hours, m: minutes, s: secs)
    end
  end
end
