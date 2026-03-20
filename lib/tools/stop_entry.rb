# frozen_string_literal: true

require "mcp"
require_relative "../duration_formatter"

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
      text = "Timer stopped:\n"
      text += "  Description: #{entry["description"] || "(no description)"}\n"
      if entry["project_id"]
        name = client.project_name(entry["project_id"])
        text += "  Project: #{name}\n" if name
        text += "  Project ID: #{entry["project_id"]}\n"
      end
      text += "  Start: #{format_time(entry["start"], tz: tz)}\n"
      text += "  Stop: #{format_time(entry["stop"], tz: tz)}\n" if entry["stop"]
      text += "  Duration: #{format_duration_human(elapsed)}\n"
      text += "  Entry ID: #{entry["id"]}"

      MCP::Tool::Response.new([{ type: "text", text: text }])
    end
  end
end
