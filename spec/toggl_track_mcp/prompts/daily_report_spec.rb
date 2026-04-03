# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Prompts::DailyReport do
  describe ".template" do
    context "without date argument" do
      it "returns a prompt result for today" do
        result = described_class.template
        expect(result.description).to include("today")
        expect(result.messages.size).to eq(1)
        expect(result.messages.first.role).to eq("user")
      end

      it "includes instructions to use get_daily_summary" do
        result = described_class.template
        text = result.messages.first.content.first.text
        expect(text).to include("get_daily_summary")
      end
    end

    context "with date argument" do
      it "includes the specified date in the prompt" do
        result = described_class.template(date: "2026-03-15")
        text = result.messages.first.content.first.text
        expect(text).to include("2026-03-15")
      end

      it "includes date in description" do
        result = described_class.template(date: "yesterday")
        expect(result.description).to include("yesterday")
      end
    end
  end
end
