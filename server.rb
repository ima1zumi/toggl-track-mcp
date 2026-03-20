# frozen_string_literal: true

require "mcp"
require_relative "lib/toggl_client"
require_relative "lib/tools/get_current_entry"
require_relative "lib/tools/get_today_entries"
require_relative "lib/tools/create_entry"
require_relative "lib/tools/update_entry"
require_relative "lib/tools/delete_entry"
require_relative "lib/tools/stop_entry"
require_relative "lib/tools/get_projects"
require_relative "lib/tools/get_daily_summary"
require_relative "lib/tools/get_entries_by_date"

server = MCP::Server.new(
  name: "toggl-track",
  version: "0.1.0",
  tools: [
    GetCurrentEntry,
    GetTodayEntries,
    CreateEntry,
    UpdateEntry,
    DeleteEntry,
    StopEntry,
    GetProjects,
    GetDailySummary,
    GetEntriesByDate,
  ],
  server_context: { client: TogglClient.new },
)

MCP::Server::Transports::StdioTransport.new(server).open
