# frozen_string_literal: true

RSpec.describe Legion::Extensions::Narrator::Runners::Narrator, 'LLM integration' do
  let(:client) { Legion::Extensions::Narrator::Client.new }

  describe '#narrate with LLM available' do
    before do
      response_double = double('response', content: 'I feel a deep sense of focus and possibility.')
      chat_double = double('chat')
      allow(chat_double).to receive(:with_instructions)
      allow(chat_double).to receive(:ask).and_return(response_double)
      llm_double = double('Legion::LLM', started?: true)
      allow(llm_double).to receive(:chat).and_return(chat_double)
      stub_const('Legion::LLM', llm_double)
    end

    it 'returns source: :llm when LLM narrate succeeds' do
      result = client.narrate(
        tick_results:    { emotional_evaluation: { valence: 0.6, arousal: 0.7 } },
        cognitive_state: {}
      )
      expect(result[:source]).to eq(:llm)
    end

    it 'returns the LLM narrative string' do
      result = client.narrate(tick_results: {}, cognitive_state: {})
      expect(result[:narrative]).to eq('I feel a deep sense of focus and possibility.')
    end

    it 'still includes mood and timestamp' do
      result = client.narrate(tick_results: {}, cognitive_state: {})
      expect(result[:mood]).to be_a(Symbol)
      expect(result[:timestamp]).to be_a(Time)
    end

    it 'appends to journal' do
      client.narrate(tick_results: {}, cognitive_state: {})
      expect(client.journal.size).to eq(1)
    end
  end

  describe '#narrate with LLM available but narrate returns nil' do
    before do
      chat_double = double('chat')
      allow(chat_double).to receive(:with_instructions)
      allow(chat_double).to receive(:ask).and_return(nil)
      llm_double = double('Legion::LLM', started?: true)
      allow(llm_double).to receive(:chat).and_return(chat_double)
      stub_const('Legion::LLM', llm_double)
    end

    it 'falls back to mechanical pipeline' do
      result = client.narrate(tick_results: {}, cognitive_state: {})
      expect(result).not_to have_key(:source)
      expect(result[:narrative]).to be_a(String)
    end
  end

  describe '#narrate when LLM is unavailable' do
    before { hide_const('Legion::LLM') }

    it 'uses mechanical pipeline without source key' do
      result = client.narrate(tick_results: {}, cognitive_state: {})
      expect(result).not_to have_key(:source)
      expect(result[:narrative]).to be_a(String)
    end

    it 'still generates mood and timestamp' do
      result = client.narrate(tick_results: {}, cognitive_state: {})
      expect(result[:mood]).to be_a(Symbol)
      expect(result[:timestamp]).to be_a(Time)
    end
  end
end
