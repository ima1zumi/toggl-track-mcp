# frozen_string_literal: true

require "webmock/rspec"
require "toggl_track_mcp"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def build_client_double(tz: "+09:00", **stubs)
  double("TogglClient", tz: tz, **stubs)
end

def response_text(response)
  response.content.first.text
end
