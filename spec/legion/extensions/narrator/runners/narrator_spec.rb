# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Runners::Narrator do
  let(:client) { Legion::Extensions::Narrator::Client.new }

  describe '#narrate' do
    it 'generates and stores a narrative entry' do
      result = client.narrate(
        tick_results:    {
          emotional_evaluation: { valence: 0.6, arousal: 0.7 },
          sensory_processing:   { spotlight: 2, peripheral: 3 }
        },
        cognitive_state: {
          curiosity: { intensity: 0.5, active_count: 2, top_question: 'What is happening?' }
        }
      )

      expect(result[:narrative]).to be_a(String)
      expect(result[:narrative]).to include('spotlight')
      expect(result[:mood]).to be_a(Symbol)
      expect(result[:timestamp]).to be_a(Time)
      expect(result[:sections]).to be_a(Hash)
    end

    it 'appends to journal' do
      client.narrate(tick_results: {}, cognitive_state: {})
      expect(client.journal.size).to eq(1)
    end

    it 'accumulates entries over multiple narrations' do
      3.times { client.narrate(tick_results: {}, cognitive_state: {}) }
      expect(client.journal.size).to eq(3)
    end
  end

  describe '#recent_entries' do
    before do
      5.times { |i| client.narrate(tick_results: { emotional_evaluation: { valence: i * 0.2 } }, cognitive_state: {}) }
    end

    it 'returns recent entries' do
      result = client.recent_entries(limit: 3)
      expect(result[:entries].size).to eq(3)
      expect(result[:count]).to eq(3)
      expect(result[:total]).to eq(5)
    end

    it 'returns all when fewer than limit' do
      result = client.recent_entries(limit: 20)
      expect(result[:entries].size).to eq(5)
    end
  end

  describe '#entries_since' do
    it 'returns entries after timestamp' do
      client.narrate(tick_results: {}, cognitive_state: {})
      cutoff = Time.now.utc
      sleep 0.01
      client.narrate(tick_results: {}, cognitive_state: {})

      result = client.entries_since(since: cutoff)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#mood_history' do
    before do
      client.narrate(
        tick_results:    { emotional_evaluation: { valence: 0.5, arousal: 0.8 } },
        cognitive_state: {}
      )
      client.narrate(
        tick_results:    { emotional_evaluation: { valence: -0.5, arousal: 0.8 } },
        cognitive_state: {}
      )
      client.narrate(
        tick_results:    { emotional_evaluation: { valence: 0.5, arousal: 0.8 } },
        cognitive_state: {}
      )
    end

    it 'returns all mood history without filter' do
      result = client.mood_history
      expect(result[:count]).to eq(3)
    end

    it 'filters by specific mood' do
      result = client.mood_history(mood: :energized)
      result[:entries].each { |e| expect(e[:mood]).to eq(:energized) }
    end
  end

  describe '#current_narrative' do
    it 'returns the most recent narrative' do
      client.narrate(tick_results: { emotional_evaluation: { valence: 0.3 } }, cognitive_state: {})
      result = client.current_narrative
      expect(result[:narrative]).to be_a(String)
      expect(result[:mood]).to be_a(Symbol)
      expect(result[:age_seconds]).to be >= 0
    end

    it 'returns default when empty' do
      result = client.current_narrative
      expect(result[:narrative]).to include('No cognitive activity')
      expect(result[:mood]).to eq(:dormant)
    end
  end

  describe '#narrator_stats' do
    it 'returns stats for empty journal' do
      stats = client.narrator_stats
      expect(stats[:journal_size]).to eq(0)
      expect(stats[:capacity]).to eq(Legion::Extensions::Narrator::Helpers::Constants::MAX_JOURNAL_SIZE)
    end

    it 'tracks mood distribution' do
      3.times { client.narrate(tick_results: { emotional_evaluation: { valence: 0.5, arousal: 0.8 } }, cognitive_state: {}) }
      stats = client.narrator_stats
      expect(stats[:journal_size]).to eq(3)
      expect(stats[:dominant_mood]).to eq(:energized)
      expect(stats[:mood_counts][:energized]).to eq(3)
    end
  end
end
