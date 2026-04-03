# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::CreateEntry do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "starting a running timer" do
      let(:entry) do
        {
          "id" => 99,
          "description" => "New task",
          "start" => "2026-04-01T10:00:00Z",
          "project_id" => nil,
          "tags" => [],
        }
      end

      before do
        allow(client).to receive(:create_entry).and_return(entry)
      end

      it "shows 'Timer started'" do
        response = described_class.call(description: "New task", server_context: server_context)
        expect(response_text(response)).to include("Timer started")
      end

      it "includes entry details" do
        response = described_class.call(description: "New task", server_context: server_context)
        text = response_text(response)
        expect(text).to include("Description: New task")
        expect(text).to include("Entry ID: 99")
      end
    end

    context "creating a completed entry" do
      let(:entry) do
        {
          "id" => 100,
          "description" => "Past task",
          "start" => "2026-04-01T09:00:00Z",
          "project_id" => 5,
          "tags" => ["dev"],
        }
      end

      before do
        allow(client).to receive(:create_entry).and_return(entry)
      end

      it "shows 'Entry created' for positive duration" do
        response = described_class.call(description: "Past task", duration: 3600, server_context: server_context)
        expect(response_text(response)).to include("Entry created")
      end

      it "includes project and tags" do
        response = described_class.call(description: "Past task", duration: 3600, server_context: server_context)
        text = response_text(response)
        expect(text).to include("Project ID: 5")
        expect(text).to include("Tags: dev")
      end
    end

    context "passing all parameters to client" do
      it "forwards all parameters" do
        allow(client).to receive(:create_entry).and_return(
          { "id" => 1, "description" => "x", "start" => "2026-04-01T00:00:00Z", "project_id" => nil, "tags" => [] },
        )

        described_class.call(
          description: "Test",
          project_id: 5,
          tags: ["a"],
          start: "2026-04-01T00:00:00Z",
          duration: 1800,
          server_context: server_context,
        )

        expect(client).to have_received(:create_entry).with(
          description: "Test",
          project_id: 5,
          tags: ["a"],
          start: "2026-04-01T00:00:00Z",
          duration: 1800,
        )
      end
    end
  end
end
