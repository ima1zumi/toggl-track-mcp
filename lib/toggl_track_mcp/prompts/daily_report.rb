# frozen_string_literal: true

require "mcp"

module TogglTrackMcp
  module Prompts
    class DailyReport < MCP::Prompt
      prompt_name "daily_report"
      title "Daily Report"
      description "Generate a daily time tracking report. Fetches today's entries and formats them as a summary."

      arguments [
        MCP::Prompt::Argument.new(
          name: "date",
          description: 'Target date (YYYY-MM-DD, "today", or "yesterday"). Defaults to today.',
          required: false,
        ),
      ]

      class << self
        def template(date: nil, server_context: nil)
          date_label = date || "today"

          MCP::Prompt::Result.new(
            description: "Daily time tracking report for #{date_label}",
            messages: [
              MCP::Prompt::Message.new(
                role: "user",
                content: [
                  MCP::Content::Text.new(
                    <<~TEXT.chomp,
                      Please generate a daily time tracking report for #{date_label}.

                      Steps:
                      1. Use the get_daily_summary tool#{date ? " with date \"#{date}\"" : ""} to fetch the data
                      2. Format the result as a clean, readable report with:
                         - A timeline of activities
                         - Total time by project
                         - Overall total hours worked
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
