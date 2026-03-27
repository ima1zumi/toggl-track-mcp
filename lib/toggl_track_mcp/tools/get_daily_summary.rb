# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Tools
    class GetDailySummary < MCP::Tool
      extend DurationFormatter

      description "Get a formatted daily summary of time entries for diary/journal use."

      annotations(
        read_only_hint: true,
        destructive_hint: false,
      )

      input_schema(
        properties: {
          date: {
            type: "string",
            description: 'Target date (YYYY-MM-DD, "today", or "yesterday"). Defaults to today.',
          },
        },
      )

      class << self
        def call(date: nil, server_context: nil)
          client = server_context[:client]
          tz = client.tz

          start_of_day = parse_date(date, tz: tz)
          end_of_day = (start_of_day + 86400).iso8601
          entries = client.entries_by_date(start_date: start_of_day.iso8601, end_date: end_of_day)

          if entries.nil? || entries.empty?
            return MCP::Tool::Response.new([{ type: "text", text: "No time entries found." }])
          end

          sorted = entries.sort_by { |e| e["start"] }

          timeline = build_timeline(sorted, client)
          project_summary = build_project_summary(sorted, client)
          total = sorted.sum { |e| entry_duration(e) }

          text = <<~TEXT
            ## Timeline
            #{timeline.chomp}

            ## By Project
            #{project_summary.chomp}

            Total: #{format_duration_human(total)}
          TEXT

          MCP::Tool::Response.new([{ type: "text", text: text }])
        end

        private

        def build_timeline(entries, client)
          tz = client.tz
          entries.map do |entry|
            start_time = format_time(entry["start"], tz: tz)
            stop_time = entry["stop"] ? format_time(entry["stop"], tz: tz) : "now"
            duration = entry_duration(entry)
            description = entry["description"] || "(no description)"
            project = client.project_name(entry["project_id"])
            label = project || description

            "#{start_time} - #{stop_time} #{label} (#{format_duration_human(duration)})\n"
          end.join
        end

        def build_project_summary(entries, client)
          by_project = Hash.new(0)
          entries.each do |entry|
            name = client.project_name(entry["project_id"]) || entry["description"] || "(no description)"
            by_project[name] += entry_duration(entry)
          end

          by_project.sort_by { |_, v| -v }.map do |name, seconds|
            "#{name}: #{format_duration_human(seconds)}\n"
          end.join
        end

        def entry_duration(entry)
          if entry["duration"] >= 0
            entry["duration"]
          else
            Time.now.to_i - Time.parse(entry["start"]).to_i
          end
        end
      end
    end
  end
end
