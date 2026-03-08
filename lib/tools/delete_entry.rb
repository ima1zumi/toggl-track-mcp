# frozen_string_literal: true

require "mcp"

class DeleteEntry < MCP::Tool
  description "Delete a time entry"

  annotations(
    destructive_hint: true,
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

      MCP::Tool::Response.new([{ type: "text", text: "Time entry #{time_entry_id} deleted." }])
    end
  end
end
