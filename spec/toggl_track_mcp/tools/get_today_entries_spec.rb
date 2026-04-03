# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::GetTodayEntries do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "when there are no entries" do
      before { allow(client).to receive(:today_entries).and_return([]) }

      it "returns a message saying no entries" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to eq("No time entries for today.")
      end
    end

    context "when entries is nil" do
      before { allow(client).to receive(:today_entries).and_return(nil) }

      it "returns a message saying no entries" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to eq("No time entries for today.")
      end
    end

    context "when there are entries" do
      let(:entries) do
        [
          {
            "id" => 1,
            "description" => "Morning standup",
            "start" => "2026-04-01T00:00:00Z",
            "stop" => "2026-04-01T00:30:00Z",
            "duration" => 1800,
            "project_id" => 10,
            "tags" => ["meeting"],
          },
          {
            "id" => 2,
            "description" => "Coding",
            "start" => "2026-04-01T01:00:00Z",
            "stop" => "2026-04-01T03:00:00Z",
            "duration" => 7200,
            "project_id" => nil,
            "tags" => [],
          },
        ]
      end

      before do
        allow(client).to receive(:today_entries).and_return(entries)
        allow(client).to receive(:project_name).with(10).and_return("Team")
        allow(client).to receive(:project_name).with(nil).and_return(nil)
      end

      it "includes entry count and total duration" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("2 total")
        expect(response_text(response)).to include("2h30min")
      end

      it "includes each entry's description" do
        response = described_class.call(server_context: server_context)
        text = response_text(response)
        expect(text).to include("Morning standup")
        expect(text).to include("Coding")
      end

      it "includes project name when present" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Project: Team")
      end
    end

    context "when an entry is still running" do
      let(:entries) do
        [
          {
            "id" => 1,
            "description" => "Running task",
            "start" => (Time.now - 600).utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "stop" => nil,
            "duration" => -1,
            "project_id" => nil,
            "tags" => [],
          },
        ]
      end

      before { allow(client).to receive(:today_entries).and_return(entries) }

      it "shows Running for active entry" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Running")
      end
    end
  end
end
