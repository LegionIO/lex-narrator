# lex-narrator

Real-time cognitive narrative stream for the LegionIO brain-modeled cognitive architecture.

## What It Does

Translates the agent's internal cognitive state into human-readable prose. Each tick, it reads emotional state, active curiosity wonders, prediction confidence, attention focus, memory health, and reflection status — then generates a timestamped narrative entry describing what the agent is experiencing.

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
#      \"Why are infrastructure traces sparse?\". ...", mood: :energized }

# Review recent narrative
client.recent_entries(limit: 5)
client.current_narrative
client.narrator_stats
```

## Mood Classification

| Mood | Valence | Arousal |
|------|---------|---------|
| `:energized` | > 0.3 | > 0.5 |
| `:content` | > 0.3 | <= 0.5 |
| `:anxious` | < -0.3 | > 0.5 |
| `:subdued` | < -0.3 | <= 0.5 |
| `:alert` | neutral | > 0.7 |
| `:dormant` | neutral | < 0.2 |
| `:neutral` | neutral | moderate |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
