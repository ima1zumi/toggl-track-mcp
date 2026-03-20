# frozen_string_literal: true

require "time"

module DurationFormatter
  def format_duration_human(seconds)
    return "0分" if seconds <= 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    if hours > 0
      "#{hours}時間#{minutes}分"
    else
      "#{minutes}分"
    end
  end

  def format_time(time_string, tz:)
    Time.parse(time_string).getlocal(tz).strftime("%H:%M")
  end

  def parse_date(date_string, tz:)
    case date_string
    when "today", nil
      today = Time.now.getlocal(tz)
      Time.new(today.year, today.month, today.day, 0, 0, 0, tz)
    when "yesterday"
      yesterday = Time.now.getlocal(tz) - 86400
      Time.new(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0, tz)
    else
      parts = date_string.split("-").map(&:to_i)
      Time.new(parts[0], parts[1], parts[2], 0, 0, 0, tz)
    end
  end
end
