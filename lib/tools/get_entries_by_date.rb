# frozen_string_literal: true

require "mcp"
require_relative "../duration_formatter"

class GetEntriesByDate < MCP::Tool
  extend DurationFormatter

  description "Get time entries by date or date range"

  annotations(
    read_only_hint: true,
    destructive_hint: false,
  )

  input_schema(
    properties: {
      date: {
        type: "string",
        description: 'YYYY-MM-DD, "today", or "yesterday"',
      },
      end_date: {
        type: "string",
        description: "Optional end date for range query (YYYY-MM-DD)",
      },
    },
    required: ["date"],
  )

  class << self
    def call(date:, end_date: nil, server_context: nil)
      client = server_context[:client]
      tz = client.tz

      start_of_day = parse_date(date, tz: tz)
      end_of_range = end_date ? parse_date(end_date, tz: tz) + 86400 : start_of_day + 86400

      entries = client.entries_by_date(
        start_date: start_of_day.iso8601,
        end_date: end_of_range.iso8601,
      )

      if entries.nil? || entries.empty?
        return MCP::Tool::Response.new([{ type: "text", text: "No time entries found." }])
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

        project_name = entry["project_id"] ? client.project_name(entry["project_id"]) : nil
        <<~TEXT.gsub(/^\s*\n/, "").chomp
            Description: #{entry["description"] || "(no description)"}
          #{"  Project: #{project_name}" if project_name}
          #{"  Project ID: #{entry["project_id"]}" if entry["project_id"]}
          #{"  Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?}
            Start: #{format_time(entry["start"], tz: tz)}
          #{"  Stop: #{format_time(entry["stop"], tz: tz)}" if entry["stop"]}
            Duration: #{format_duration_human(duration)}
          #{"  Running" if entry["duration"] < 0}
            Entry ID: #{entry["id"]}
        TEXT
      end

      text = <<~TEXT.chomp
        Entries (#{entries.size} total, #{format_duration_human(total_seconds)}):

        #{lines.join("\n\n")}
      TEXT

      MCP::Tool::Response.new([{ type: "text", text: text }])
    end
  end
end
