# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Tools
    class StopEntry < MCP::Tool
      extend DurationFormatter

      description "Stop the currently running timer"

      input_schema(properties: {})

      class << self
        def call(server_context: nil)
          client = server_context[:client]
          current = client.current_entry

          if current.nil?
            return MCP::Tool::Response.new([{ type: "text", text: "No timer is currently running." }])
          end

          entry = client.stop_entry(time_entry_id: current["id"])

          tz = client.tz
          elapsed = Time.now.to_i - Time.parse(entry["start"]).to_i
          project_name = entry["project_id"] ? client.project_name(entry["project_id"]) : nil
          text = <<~TEXT.gsub(/^\s*\n/, "").chomp
            Timer stopped:
              Description: #{entry["description"] || "(no description)"}
            #{"  Project: #{project_name}" if project_name}
            #{"  Project ID: #{entry["project_id"]}" if entry["project_id"]}
              Start: #{format_time(entry["start"], tz: tz)}
            #{"  Stop: #{format_time(entry["stop"], tz: tz)}" if entry["stop"]}
              Duration: #{format_duration_human(elapsed)}
              Entry ID: #{entry["id"]}
          TEXT

          MCP::Tool::Response.new([{ type: "text", text: text }])
        end
      end
    end
  end
end
