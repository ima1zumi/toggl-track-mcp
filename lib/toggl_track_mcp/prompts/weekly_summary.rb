# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Prompts
    class WeeklySummary < MCP::Prompt
      prompt_name "weekly_summary"
      title "Weekly Summary"
      description "Generate a weekly time tracking summary. Fetches entries for the past 7 days and summarizes by project."

      class << self
        def template(server_context: nil)
          MCP::Prompt::Result.new(
            description: "Weekly time tracking summary",
            messages: [
              MCP::Prompt::Message.new(
                role: "user",
                content: [
                  MCP::Content::Text.new(
                    <<~TEXT.chomp,
                      Please generate a weekly time tracking summary for the past 7 days.

                      Steps:
                      1. Use get_entries_by_date for each of the last 7 days to collect all entries
                      2. Summarize the data with:
                         - Total hours per day
                         - Total hours per project across the week
                         - Overall total for the week
                         - A brief comparison of which days were most/least productive
                    TEXT
                  ),
                ],
              ),
            ],
          )
        end
      end
    end
  end
end
