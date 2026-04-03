# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::GetProjects do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "when no projects" do
      before { allow(client).to receive(:projects).and_return([]) }

      it "returns a message saying no projects" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to eq("No projects found.")
      end
    end

    context "with projects" do
      let(:projects) do
        [
          { "id" => 1, "name" => "Project A", "active" => true, "color" => "#ff0000" },
          { "id" => 2, "name" => "Project B", "active" => true, "color" => nil },
          { "id" => 3, "name" => "Archived", "active" => false, "color" => "#000000" },
        ]
      end

      before { allow(client).to receive(:projects).and_return(projects) }

      it "lists only active projects" do
        response = described_class.call(server_context: server_context)
        text = response_text(response)
        expect(text).to include("Project A")
        expect(text).to include("Project B")
        expect(text).not_to include("Archived")
      end

      it "shows correct count of active projects" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Projects (2)")
      end

      it "includes color when present" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Color: #ff0000")
      end

      it "includes project IDs" do
        response = described_class.call(server_context: server_context)
        text = response_text(response)
        expect(text).to include("ID: 1")
        expect(text).to include("ID: 2")
      end
    end
  end
end
