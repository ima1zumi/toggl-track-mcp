# frozen_string_literal: true

require_relative "toggl_track_mcp/version"
require_relative "toggl_track_mcp/duration_formatter"
require_relative "toggl_track_mcp/toggl_client"
require_relative "toggl_track_mcp/tools/get_current_entry"
require_relative "toggl_track_mcp/tools/get_today_entries"
require_relative "toggl_track_mcp/tools/get_entries_by_date"
require_relative "toggl_track_mcp/tools/get_daily_summary"
require_relative "toggl_track_mcp/tools/get_projects"
require_relative "toggl_track_mcp/tools/create_entry"
require_relative "toggl_track_mcp/tools/update_entry"
require_relative "toggl_track_mcp/tools/stop_entry"
require_relative "toggl_track_mcp/tools/delete_entry"
require_relative "toggl_track_mcp/prompts/daily_report"
require_relative "toggl_track_mcp/prompts/weekly_summary"

module TogglTrackMcp
  TOOLS = [
    Tools::GetCurrentEntry,
    Tools::GetTodayEntries,
    Tools::GetEntriesByDate,
    Tools::GetDailySummary,
    Tools::GetProjects,
    Tools::CreateEntry,
    Tools::UpdateEntry,
    Tools::StopEntry,
    Tools::DeleteEntry,
  ].freeze

  PROMPTS = [
    Prompts::DailyReport,
    Prompts::WeeklySummary,
  ].freeze
end
