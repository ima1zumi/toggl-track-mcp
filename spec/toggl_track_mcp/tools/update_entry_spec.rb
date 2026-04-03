# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::UpdateEntry do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "when no fields provided" do
      it "returns an error response" do
        response = described_class.call(time_entry_id: 42, server_context: server_context)
        expect(response_text(response)).to include("No fields to update")
        expect(response.error?).to be true
      end
    end

    context "when updating description" do
      let(:entry) do
        {
          "id" => 42,
          "description" => "Updated task",
          "project_id" => nil,
          "tags" => [],
          "start" => "2026-04-01T00:00:00Z",
          "stop" => "2026-04-01T01:00:00Z",
        }
      end

      before do
        allow(client).to receive(:update_entry).and_return(entry)
      end

      it "shows updated entry" do
        response = described_class.call(
          time_entry_id: 42,
          description: "Updated task",
          server_context: server_context,
        )
        text = response_text(response)
        expect(text).to include("Entry updated")
        expect(text).to include("Description: Updated task")
        expect(text).to include("Entry ID: 42")
      end
    end

    context "when updating multiple fields" do
      before do
        allow(client).to receive(:update_entry).and_return(
          { "id" => 42, "description" => "x", "project_id" => 5, "tags" => ["a", "b"], "start" => nil, "stop" => nil },
        )
      end

      it "forwards only provided params to client" do
        described_class.call(
          time_entry_id: 42,
          description: "x",
          project_id: 5,
          tags: ["a", "b"],
          server_context: server_context,
        )

        expect(client).to have_received(:update_entry).with(
          time_entry_id: 42,
          description: "x",
          project_id: 5,
          tags: ["a", "b"],
        )
      end
    end
  end
end
