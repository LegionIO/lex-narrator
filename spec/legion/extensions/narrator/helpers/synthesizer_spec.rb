# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Helpers::Synthesizer do
  let(:synth) { described_class }

  describe '.narrate' do
    it 'produces a narrative entry with all sections' do
      result = synth.narrate(
        tick_results:    {
          emotional_evaluation: { valence: 0.5, arousal: 0.8 },
          sensory_processing:   { spotlight: 2, peripheral: 4 }
        },
        cognitive_state: {
          curiosity: { intensity: 0.6, active_count: 3, top_question: 'Why?' }
        }
      )

      expect(result[:narrative]).to be_a(String)
      expect(result[:narrative].length).to be > 10
      expect(result[:mood]).to be_a(Symbol)
      expect(result[:timestamp]).to be_a(Time)
      expect(result[:sections]).to have_key(:attention)
      expect(result[:sections]).to have_key(:emotion)
      expect(result[:sections]).to have_key(:curiosity)
      expect(result[:sections]).to have_key(:prediction)
      expect(result[:sections]).to have_key(:memory)
      expect(result[:sections]).to have_key(:reflection)
    end

    it 'handles empty inputs gracefully' do
      result = synth.narrate(tick_results: {}, cognitive_state: {})
      expect(result[:narrative]).to be_a(String)
      expect(result[:mood]).to eq(:neutral)
    end
  end

  describe '.infer_mood' do
    it 'returns :energized for positive valence + high arousal' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: 0.5, arousal: 0.7 } }, {})).to eq(:energized)
    end

    it 'returns :content for positive valence + low arousal' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: 0.5, arousal: 0.3 } }, {})).to eq(:content)
    end

    it 'returns :anxious for negative valence + high arousal' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: -0.5, arousal: 0.7 } }, {})).to eq(:anxious)
    end

    it 'returns :subdued for negative valence + low arousal' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: -0.5, arousal: 0.3 } }, {})).to eq(:subdued)
    end

    it 'returns :alert for neutral valence + very high arousal' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: 0.0, arousal: 0.9 } }, {})).to eq(:alert)
    end

    it 'returns :dormant for neutral valence + very low arousal' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: 0.0, arousal: 0.1 } }, {})).to eq(:dormant)
    end

    it 'returns :neutral for moderate values' do
      expect(synth.infer_mood({ emotional_evaluation: { valence: 0.0, arousal: 0.5 } }, {})).to eq(:neutral)
    end
  end

  describe '.classify_mood' do
    it 'classifies all seven moods' do
      expect(synth.classify_mood(0.5, 0.8)).to eq(:energized)
      expect(synth.classify_mood(0.5, 0.3)).to eq(:content)
      expect(synth.classify_mood(-0.5, 0.8)).to eq(:anxious)
      expect(synth.classify_mood(-0.5, 0.3)).to eq(:subdued)
      expect(synth.classify_mood(0.0, 0.9)).to eq(:alert)
      expect(synth.classify_mood(0.0, 0.1)).to eq(:dormant)
      expect(synth.classify_mood(0.0, 0.5)).to eq(:neutral)
    end
  end

  describe '.extract_focused_domains' do
    it 'extracts domain names from manual_focus hash' do
      focus = { manual_focus: { terraform: {}, vault: {} } }
      expect(synth.extract_focused_domains(focus)).to eq(%w[terraform vault])
    end

    it 'returns empty array for nil' do
      expect(synth.extract_focused_domains({})).to eq([])
    end
  end
end
