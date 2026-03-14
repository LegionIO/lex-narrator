# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Helpers::Prose do
  let(:prose) { described_class }

  describe '.emotion_phrase' do
    it 'describes high positive valence with high arousal' do
      result = prose.emotion_phrase(valence: 0.8, arousal: 0.9)
      expect(result).to include('highly alert')
      expect(result).to include('engaged and optimistic')
    end

    it 'describes low negative valence' do
      result = prose.emotion_phrase(valence: -0.4, arousal: 0.3)
      expect(result).to include('slightly uneasy')
    end

    it 'includes gut signal when strong positive' do
      result = prose.emotion_phrase(valence: 0.0, arousal: 0.5, gut: { signal: 0.5 })
      expect(result).to include('something important')
    end

    it 'includes gut signal when strong negative' do
      result = prose.emotion_phrase(valence: 0.0, arousal: 0.5, gut: { signal: -0.5 })
      expect(result).to include('uneasy feeling')
    end

    it 'omits gut note when signal is mild' do
      result = prose.emotion_phrase(valence: 0.0, arousal: 0.5, gut: { signal: 0.1 })
      expect(result).not_to include('gut')
      expect(result).not_to include('important')
    end
  end

  describe '.curiosity_phrase' do
    it 'describes high curiosity with wonders' do
      result = prose.curiosity_phrase(intensity: 0.8, top_wonder: 'Why are traces sparse?', wonder_count: 3)
      expect(result).to include('deeply curious')
      expect(result).to include('3 open questions')
      expect(result).to include('Why are traces sparse?')
    end

    it 'describes no curiosity' do
      result = prose.curiosity_phrase(intensity: 0.0)
      expect(result).to include('not particularly curious')
    end

    it 'handles single wonder' do
      result = prose.curiosity_phrase(intensity: 0.5, top_wonder: 'What is this?', wonder_count: 1)
      expect(result).to include('1 open question')
    end
  end

  describe '.prediction_phrase' do
    it 'describes high confidence' do
      result = prose.prediction_phrase(confidence: 0.9, pending: 2, mode: :functional_mapping)
      expect(result).to include('confident')
      expect(result).to include('functional_mapping')
      expect(result).to include('2 pending predictions')
    end

    it 'describes low confidence' do
      result = prose.prediction_phrase(confidence: 0.2)
      expect(result).to include('uncertain')
    end
  end

  describe '.attention_phrase' do
    it 'describes spotlight and peripheral counts' do
      result = prose.attention_phrase(spotlight: 3, peripheral: 5)
      expect(result).to include('3 signals in spotlight')
      expect(result).to include('5 in peripheral')
    end

    it 'includes manual focus domains' do
      result = prose.attention_phrase(spotlight: 1, peripheral: 0, focused_domains: %w[terraform vault])
      expect(result).to include('terraform')
      expect(result).to include('vault')
    end
  end

  describe '.memory_phrase' do
    it 'describes memory state' do
      result = prose.memory_phrase(trace_count: 150, health: 0.85)
      expect(result).to include('150 active traces')
      expect(result).to include('functioning well')
    end
  end

  describe '.reflection_phrase' do
    it 'describes healthy state' do
      result = prose.reflection_phrase(health: 0.95)
      expect(result).to include('operating at full capacity')
    end

    it 'includes pending adaptations' do
      result = prose.reflection_phrase(health: 0.6, pending_adaptations: 3, recent_severity: :significant)
      expect(result).to include('3 pending adaptation')
      expect(result).to include('significant')
    end
  end

  describe '.overall_narrative' do
    it 'joins sections with periods' do
      result = prose.overall_narrative(['I am alert', 'I am curious', 'Memory is good'])
      expect(result).to eq('I am alert. I am curious. Memory is good.')
    end

    it 'skips empty sections' do
      result = prose.overall_narrative(['I am alert', '', nil, 'Memory is good'])
      expect(result).to eq('I am alert. Memory is good.')
    end
  end

  describe '.emotion_label_for' do
    it 'returns correct labels for valence ranges' do
      expect(prose.emotion_label_for(0.8)).to eq('engaged and optimistic')
      expect(prose.emotion_label_for(0.3)).to eq('calm and steady')
      expect(prose.emotion_label_for(0.0)).to eq('emotionally neutral')
      expect(prose.emotion_label_for(-0.3)).to eq('slightly uneasy')
      expect(prose.emotion_label_for(-0.8)).to eq('distressed')
    end
  end

  describe '.health_label_for' do
    it 'returns correct labels for health ranges' do
      expect(prose.health_label_for(0.95)).to eq('operating at full capacity')
      expect(prose.health_label_for(0.8)).to eq('functioning well overall')
      expect(prose.health_label_for(0.6)).to eq('showing some strain')
      expect(prose.health_label_for(0.4)).to eq('experiencing significant cognitive difficulty')
      expect(prose.health_label_for(0.2)).to eq('in cognitive distress')
    end
  end
end
