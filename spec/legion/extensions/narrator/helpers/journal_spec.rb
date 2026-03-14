# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Helpers::Journal do
  subject(:journal) { described_class.new }

  let(:entry) do
    { timestamp: Time.now.utc, narrative: 'I am alert.', mood: :energized, sections: {} }
  end

  describe '#append' do
    it 'adds an entry' do
      journal.append(entry)
      expect(journal.size).to eq(1)
    end

    it 'returns the appended entry' do
      result = journal.append(entry)
      expect(result[:narrative]).to eq('I am alert.')
    end

    it 'trims to MAX_JOURNAL_SIZE' do
      max = Legion::Extensions::Narrator::Helpers::Constants::MAX_JOURNAL_SIZE
      (max + 10).times { |i| journal.append(entry.merge(narrative: "Entry #{i}")) }
      expect(journal.size).to eq(max)
    end
  end

  describe '#recent' do
    it 'returns last N entries' do
      5.times { |i| journal.append(entry.merge(narrative: "Entry #{i}")) }
      result = journal.recent(limit: 3)
      expect(result.size).to eq(3)
      expect(result.last[:narrative]).to eq('Entry 4')
    end

    it 'returns all entries when fewer than limit' do
      2.times { |i| journal.append(entry.merge(narrative: "Entry #{i}")) }
      expect(journal.recent(limit: 10).size).to eq(2)
    end
  end

  describe '#since' do
    it 'returns entries after a timestamp' do
      old = entry.merge(timestamp: Time.now.utc - 3600)
      recent_entry = entry.merge(timestamp: Time.now.utc)

      journal.append(old)
      journal.append(recent_entry)

      cutoff = Time.now.utc - 1800
      result = journal.since(cutoff)
      expect(result.size).to eq(1)
    end
  end

  describe '#by_mood' do
    it 'filters entries by mood' do
      journal.append(entry.merge(mood: :energized))
      journal.append(entry.merge(mood: :dormant))
      journal.append(entry.merge(mood: :energized))

      result = journal.by_mood(:energized)
      expect(result.size).to eq(2)
    end
  end

  describe '#stats' do
    it 'returns empty stats for empty journal' do
      stats = journal.stats
      expect(stats[:total]).to eq(0)
      expect(stats[:moods]).to eq({})
    end

    it 'returns mood distribution and timestamps' do
      journal.append(entry.merge(mood: :energized))
      journal.append(entry.merge(mood: :neutral))
      journal.append(entry.merge(mood: :energized))

      stats = journal.stats
      expect(stats[:total]).to eq(3)
      expect(stats[:moods][:energized]).to eq(2)
      expect(stats[:moods][:neutral]).to eq(1)
      expect(stats).to have_key(:oldest)
      expect(stats).to have_key(:newest)
    end
  end

  describe '#clear' do
    it 'removes all entries' do
      3.times { journal.append(entry) }
      journal.clear
      expect(journal.size).to eq(0)
    end
  end
end
