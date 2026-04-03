# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Prompts::WeeklySummary do
  describe ".template" do
    it "returns a prompt result" do
      result = described_class.template
      expect(result.description).to include("Weekly")
      expect(result.messages.size).to eq(1)
    end

    it "includes instructions to use get_entries_by_date" do
      result = described_class.template
      text = result.messages.first.content.first.text
      expect(text).to include("get_entries_by_date")
    end

    it "mentions past 7 days" do
      result = described_class.template
      text = result.messages.first.content.first.text
      expect(text).to include("7 days")
    end
  end
end
