# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::GetEntriesByDate do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "when no entries found" do
      before do
        allow(client).to receive(:entries_by_date).and_return([])
      end

      it "returns a message saying no entries" do
        response = described_class.call(date: "2026-03-15", server_context: server_context)
        expect(response_text(response)).to eq("No time entries found.")
      end
    end

    context "with a single date" do
      let(:entries) do
        [
          {
            "id" => 1,
            "description" => "Task A",
            "start" => "2026-03-15T00:00:00+09:00",
            "stop" => "2026-03-15T01:00:00+09:00",
            "duration" => 3600,
            "project_id" => nil,
            "tags" => [],
          },
        ]
      end

      before do
        allow(client).to receive(:entries_by_date).and_return(entries)
      end

      it "returns formatted entries" do
        response = described_class.call(date: "2026-03-15", server_context: server_context)
        text = response_text(response)
        expect(text).to include("1 total")
        expect(text).to include("1h0min")
        expect(text).to include("Task A")
      end
    end

    context "with a date range" do
      before do
        allow(client).to receive(:entries_by_date).and_return([
          { "id" => 1, "description" => "Day 1", "start" => "2026-03-15T00:00:00+09:00",
            "stop" => "2026-03-15T01:00:00+09:00", "duration" => 3600, "project_id" => nil, "tags" => [] },
          { "id" => 2, "description" => "Day 2", "start" => "2026-03-16T00:00:00+09:00",
            "stop" => "2026-03-16T02:00:00+09:00", "duration" => 7200, "project_id" => nil, "tags" => [] },
        ])
      end

      it "returns entries across the range" do
        response = described_class.call(date: "2026-03-15", end_date: "2026-03-16", server_context: server_context)
        text = response_text(response)
        expect(text).to include("2 total")
        expect(text).to include("Day 1")
        expect(text).to include("Day 2")
      end
    end
  end
end
