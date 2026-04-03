# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::GetDailySummary do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "when no entries found" do
      before do
        allow(client).to receive(:entries_by_date).and_return([])
      end

      it "returns a message saying no entries" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to eq("No time entries found.")
      end
    end

    context "with entries" do
      let(:entries) do
        [
          {
            "id" => 1,
            "description" => "Coding",
            "start" => "2026-04-01T00:00:00Z",
            "stop" => "2026-04-01T02:00:00Z",
            "duration" => 7200,
            "project_id" => 10,
          },
          {
            "id" => 2,
            "description" => "Review",
            "start" => "2026-04-01T03:00:00Z",
            "stop" => "2026-04-01T04:00:00Z",
            "duration" => 3600,
            "project_id" => 10,
          },
          {
            "id" => 3,
            "description" => "Meeting",
            "start" => "2026-04-01T05:00:00Z",
            "stop" => "2026-04-01T05:30:00Z",
            "duration" => 1800,
            "project_id" => 20,
          },
        ]
      end

      before do
        allow(client).to receive(:entries_by_date).and_return(entries)
        allow(client).to receive(:project_name).with(10).and_return("Development")
        allow(client).to receive(:project_name).with(20).and_return("Meetings")
      end

      it "includes Timeline section" do
        response = described_class.call(date: "2026-04-01", server_context: server_context)
        expect(response_text(response)).to include("## Timeline")
      end

      it "includes By Project section" do
        response = described_class.call(date: "2026-04-01", server_context: server_context)
        expect(response_text(response)).to include("## By Project")
      end

      it "includes total duration" do
        response = described_class.call(date: "2026-04-01", server_context: server_context)
        expect(response_text(response)).to include("Total: 3h30min")
      end

      it "shows project names in timeline" do
        response = described_class.call(date: "2026-04-01", server_context: server_context)
        text = response_text(response)
        expect(text).to include("Development")
        expect(text).to include("Meetings")
      end

      it "aggregates time by project" do
        response = described_class.call(date: "2026-04-01", server_context: server_context)
        text = response_text(response)
        expect(text).to include("Development: 3h0min")
        expect(text).to include("Meetings: 30min")
      end
    end
  end
end
