# lex-narrator

Real-time cognitive narrative stream for the LegionIO cognitive architecture. Translates the agent's internal cognitive state into human-readable prose each tick.

## What It Does

Each tick, reads emotional state, active curiosity wonders, prediction confidence, attention focus, memory health, and reflection status from `tick_results` and `cognitive_state`, then generates a timestamped narrative entry. Entries are appended to a rolling journal (capped at 500). Provides mood classification, journal queries, and statistics.

## Usage

```ruby
client = Legion::Extensions::Narrator::Client.new

# Generate narrative from tick results
entry = client.narrate(
  tick_results: {
    emotional_evaluation: { valence: 0.4, arousal: 0.7 },
    sensory_processing:   { spotlight: 3, peripheral: 5 },
    prediction_engine:    { confidence: 0.6, mode: :functional_mapping }
  },
  cognitive_state: {
    curiosity: { intensity: 0.8, active_count: 4, top_question: 'Why are infrastructure traces sparse?' }
  }
)
# => { narrative: "3 signals in spotlight focus, 5 in peripheral awareness. I am highly alert
#      and calm and steady. I am deeply curious, with 4 open questions. Most pressing:
#      \"Why are infrastructure traces sparse?\"...", mood: :energized }

# Query journal
client.recent_entries(limit: 5)
client.entries_since(since: Time.now - 3600)
client.mood_history(mood: :anxious, limit: 10)
client.current_narrative
client.narrator_stats
```

## Mood Classification

| Mood | Condition |
|------|-----------|
| `:energized` | valence > 0.3, arousal > 0.5 |
| `:content` | valence > 0.3, arousal <= 0.5 |
| `:anxious` | valence < -0.3, arousal > 0.5 |
| `:subdued` | valence < -0.3, arousal <= 0.5 |
| `:alert` | neutral valence, arousal > 0.7 |
| `:dormant` | neutral valence, arousal < 0.2 |
| `:neutral` | neutral valence, moderate arousal |

## LLM Enhancement

When `legion-llm` is loaded and started, `Helpers::LlmEnhancer` replaces the mechanical `Prose.*` sentence-concatenation pipeline with a single LLM-generated narrative.

**Method**: `LlmEnhancer.narrate(sections_data:)`

Accepts a hash of six cognitive domains — `emotion`, `curiosity`, `prediction`, `memory`, `attention`, and `reflection` — assembled by the runner from `tick_results` and `cognitive_state`. Sends the metrics to the LLM with a system prompt instructing it to write a 3-5 sentence first-person internal monologue (present tense, vivid, no raw numbers). Returns the generated narrative string, or `nil` on failure.

**Availability gate**: `LlmEnhancer.available?` checks `Legion::LLM.started?`. Returns `false` if `legion-llm` is not loaded, not configured, or raises any error — the check is fully safe to call unconditionally.

**Fallback**: When LLM is unavailable or `narrate` returns `nil`, the existing `Helpers::Prose` label-based pipeline runs unchanged. The runner includes `source: :llm` in the result hash only when the LLM path is taken.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
