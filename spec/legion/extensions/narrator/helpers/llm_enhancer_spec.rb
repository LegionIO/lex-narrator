# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Helpers::LlmEnhancer do
  describe '.available?' do
    context 'when Legion::LLM is not defined' do
      it 'returns false' do
        hide_const('Legion::LLM')
        expect(described_class.available?).to be false
      end
    end

    context 'when Legion::LLM is defined but not started' do
      it 'returns false' do
        llm_double = double('Legion::LLM', started?: false)
        stub_const('Legion::LLM', llm_double)
        expect(described_class.available?).to be false
      end
    end

    context 'when Legion::LLM is started' do
      it 'returns true' do
        llm_double = double('Legion::LLM', started?: true)
        stub_const('Legion::LLM', llm_double)
        expect(described_class.available?).to be true
      end
    end

    context 'when Legion::LLM raises an error' do
      it 'returns false' do
        llm_double = double('Legion::LLM')
        allow(llm_double).to receive(:respond_to?).and_raise(StandardError)
        stub_const('Legion::LLM', llm_double)
        expect(described_class.available?).to be false
      end
    end
  end

  describe '.narrate' do
    let(:sections_data) do
      {
        emotion:    { valence: 0.6, arousal: 0.7, gut: nil },
        curiosity:  { intensity: 0.5, wonder_count: 3, top_wonder: 'What is next?' },
        prediction: { confidence: 0.8, pending: 2, mode: :causal },
        memory:     { trace_count: 42, health: 0.9 },
        attention:  { spotlight: 4, peripheral: 2, focused_domains: ['planning'] },
        reflection: { health: 0.95, pending_adaptations: 1 }
      }
    end

    context 'when LLM returns a response' do
      it 'returns the response content as a string' do
        response_double = double('response', content: 'I feel alert and curious about what lies ahead.')
        chat_double = double('chat')
        allow(chat_double).to receive(:with_instructions)
        allow(chat_double).to receive(:ask).and_return(response_double)
        llm_double = double('Legion::LLM', started?: true)
        allow(llm_double).to receive(:chat).and_return(chat_double)
        stub_const('Legion::LLM', llm_double)

        result = described_class.narrate(sections_data: sections_data)
        expect(result).to be_a(String)
        expect(result).to eq('I feel alert and curious about what lies ahead.')
      end
    end

    context 'when LLM returns nil response' do
      it 'returns nil' do
        chat_double = double('chat')
        allow(chat_double).to receive(:with_instructions)
        allow(chat_double).to receive(:ask).and_return(nil)
        llm_double = double('Legion::LLM', started?: true)
        allow(llm_double).to receive(:chat).and_return(chat_double)
        stub_const('Legion::LLM', llm_double)

        result = described_class.narrate(sections_data: sections_data)
        expect(result).to be_nil
      end
    end

    context 'when an error occurs' do
      it 'returns nil and logs a warning' do
        llm_double = double('Legion::LLM', started?: true)
        allow(llm_double).to receive(:chat).and_raise(StandardError, 'connection failed')
        stub_const('Legion::LLM', llm_double)

        expect(Legion::Logging).to receive(:warn).with(/narrator:llm.*narrate failed/)
        result = described_class.narrate(sections_data: sections_data)
        expect(result).to be_nil
      end
    end

    context 'with empty sections_data' do
      it 'does not raise and returns a string when LLM responds' do
        response_double = double('response', content: 'Everything seems quiet.')
        chat_double = double('chat')
        allow(chat_double).to receive(:with_instructions)
        allow(chat_double).to receive(:ask).and_return(response_double)
        llm_double = double('Legion::LLM', started?: true)
        allow(llm_double).to receive(:chat).and_return(chat_double)
        stub_const('Legion::LLM', llm_double)

        result = described_class.narrate(sections_data: {})
        expect(result).to eq('Everything seems quiet.')
      end
    end
  end
end
