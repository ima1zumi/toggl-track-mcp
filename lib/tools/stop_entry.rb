# frozen_string_literal: true

require "mcp"

class StopEntry < MCP::Tool
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

      elapsed = Time.now.to_i - Time.parse(entry["start"]).to_i
      text = "Timer stopped:\n"
      text += "  Description: #{entry["description"] || "(no description)"}\n"
      text += "  Duration: #{format_duration(elapsed)}\n"
      text += "  Entry ID: #{entry["id"]}"

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
