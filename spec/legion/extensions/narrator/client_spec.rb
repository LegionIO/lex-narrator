# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Client do
  subject(:client) { described_class.new }

  it 'initializes with a default journal' do
    expect(client.journal).to be_a(Legion::Extensions::Narrator::Helpers::Journal)
  end

  it 'accepts an injected journal' do
    custom = Legion::Extensions::Narrator::Helpers::Journal.new
    client = described_class.new(journal: custom)
    expect(client.journal).to be(custom)
  end

  it 'includes the Narrator runner' do
    expect(client).to respond_to(:narrate)
    expect(client).to respond_to(:recent_entries)
    expect(client).to respond_to(:entries_since)
    expect(client).to respond_to(:mood_history)
    expect(client).to respond_to(:current_narrative)
    expect(client).to respond_to(:narrator_stats)
  end
end
