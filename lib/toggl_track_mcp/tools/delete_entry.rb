# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Tools
    class DeleteEntry < MCP::Tool
      tool_name "delete_entry"
      title "Delete Entry"
      description "Delete a time entry"

      annotations(
        read_only_hint: false,
        destructive_hint: true,
        idempotent_hint: true,
        open_world_hint: true,
      )

      input_schema(
        properties: {
          time_entry_id: {
            type: "integer",
            description: "The ID of the time entry to delete",
          },
        },
        required: ["time_entry_id"],
      )

      class << self
        def call(time_entry_id:, server_context: nil)
          client = server_context[:client]
          client.delete_entry(time_entry_id: time_entry_id)

          MCP::Tool::Response.new([MCP::Content::Text.new("Time entry #{time_entry_id} deleted.")])
        end
      end
    end
  end
end
