# frozen_string_literal: true

RSpec.describe TogglTrackMcp::DurationFormatter do
  let(:formatter) do
    Class.new { extend TogglTrackMcp::DurationFormatter }
  end

  describe "#format_duration_human" do
    it "returns '0min' for 0 seconds" do
      expect(formatter.format_duration_human(0)).to eq("0min")
    end

    it "returns '0min' for negative seconds" do
      expect(formatter.format_duration_human(-100)).to eq("0min")
    end

    it "formats minutes only" do
      expect(formatter.format_duration_human(300)).to eq("5min")
    end

    it "formats hours and minutes" do
      expect(formatter.format_duration_human(3660)).to eq("1h1min")
    end

    it "formats exact hours" do
      expect(formatter.format_duration_human(7200)).to eq("2h0min")
    end

    it "formats large durations" do
      expect(formatter.format_duration_human(36000)).to eq("10h0min")
    end
  end

  describe "#format_time" do
    it "formats UTC time to local timezone" do
      expect(formatter.format_time("2026-04-01T00:00:00Z", tz: "+09:00")).to eq("09:00")
    end

    it "handles different timezones" do
      expect(formatter.format_time("2026-04-01T12:30:00Z", tz: "+00:00")).to eq("12:30")
    end
  end

  describe "#parse_date" do
    let(:tz) { "+09:00" }

    it "parses 'today'" do
      result = formatter.parse_date("today", tz: tz)
      today = Time.now.getlocal(tz)
      expect(result.year).to eq(today.year)
      expect(result.month).to eq(today.month)
      expect(result.day).to eq(today.day)
      expect(result.hour).to eq(0)
      expect(result.min).to eq(0)
      expect(result.utc_offset).to eq(9 * 3600)
    end

    it "parses nil as today" do
      result = formatter.parse_date(nil, tz: tz)
      today = Time.now.getlocal(tz)
      expect(result.day).to eq(today.day)
    end

    it "parses 'yesterday'" do
      result = formatter.parse_date("yesterday", tz: tz)
      yesterday = Time.now.getlocal(tz) - 86400
      expect(result.year).to eq(yesterday.year)
      expect(result.month).to eq(yesterday.month)
      expect(result.day).to eq(yesterday.day)
    end

    it "parses YYYY-MM-DD format" do
      result = formatter.parse_date("2026-03-15", tz: tz)
      expect(result.year).to eq(2026)
      expect(result.month).to eq(3)
      expect(result.day).to eq(15)
      expect(result.hour).to eq(0)
    end
  end
end
