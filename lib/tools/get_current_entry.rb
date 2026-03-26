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
      start_time = Time.parse(entry["start"])
      elapsed = Time.now.to_i - start_time.to_i
      project_name = entry["project_id"] ? client.project_name(entry["project_id"]) : nil

      <<~TEXT.gsub(/^\s*\n/, "").chomp
        Description: #{entry["description"] || "(no description)"}
        #{"Project: #{project_name}" if project_name}
        #{"Project ID: #{entry["project_id"]}" if entry["project_id"]}
        #{"Tags: #{entry["tags"].join(", ")}" if entry["tags"]&.any?}
        Start: #{start_time.getlocal(tz).strftime("%H:%M")} (#{format_duration_human(elapsed)} elapsed)
        Entry ID: #{entry["id"]}
      TEXT
    end
  end
end
