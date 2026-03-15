# lex-narrator

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-narrator`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::Narrator`

## Purpose

Real-time cognitive narrative stream. Each tick, translates the agent's current internal state (emotion, curiosity, prediction confidence, attention, memory health, reflection status) into a human-readable prose entry and appends it to a rolling journal. Provides mood classification and journal query methods.

## Gem Info

- **Gemspec**: `lex-narrator.gemspec`
- **Homepage**: https://github.com/LegionIO/lex-narrator
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/narrator/
  version.rb
  client.rb
  helpers/
    constants.rb     # Label maps: EMOTION_LABELS, AROUSAL_LABELS, CURIOSITY_LABELS,
                     # CONFIDENCE_LABELS, HEALTH_LABELS, MODES, SECTIONS
    prose.rb         # Prose module_function — sentence generators per cognitive domain
    synthesizer.rb   # Synthesizer module_function — assembles sections from tick_results + cognitive_state
    journal.rb       # Journal class — rolling entry store
  helpers/
    llm_enhancer.rb  # LlmEnhancer module — optional LLM narrative generation
  runners/
    narrator.rb      # Runner module — narrate, recent_entries, entries_since, mood_history, etc.
spec/
  helpers/constants_spec.rb (implied)
  helpers/prose_spec.rb
  helpers/synthesizer_spec.rb
  helpers/journal_spec.rb
  runners/narrator_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `MAX_JOURNAL_SIZE = 500`
- `MODES = %i[mechanical enhanced]`
- `SECTIONS = %i[attention emotion curiosity prediction memory reflection identity overall]`
- `EMOTION_LABELS`: valence buckets -> prose strings (`'engaged and optimistic'`, etc.)
- `AROUSAL_LABELS`: arousal buckets -> prose strings
- `CURIOSITY_LABELS`, `CONFIDENCE_LABELS`, `HEALTH_LABELS`: similarly structured

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `narrate` | `tick_results: {}`, `cognitive_state: {}` | `{ narrative:, mood:, timestamp:, sections: }` |
| `recent_entries` | `limit: 10` | `{ entries:, count:, total: }` |
| `entries_since` | `since:` (Time or parseable string) | `{ entries:, count:, since: }` |
| `mood_history` | `mood:` (optional filter), `limit: 20` | `{ entries:, count:, mood: }` |
| `current_narrative` | — | last journal entry with `age_seconds` |
| `narrator_stats` | — | `{ journal_size:, capacity:, dominant_mood:, mood_counts:, oldest:, newest: }` |

## Helpers

### `Helpers::Prose` (module_function)
Stateless sentence generators:
- `emotion_phrase(valence:, arousal:, gut:)` — builds "I am [arousal_label] and [emotion_label]" with optional gut note
- `curiosity_phrase(intensity:, top_wonder:, wonder_count:)` — curiosity sentence with active question count
- `prediction_phrase(confidence:, pending:, mode:)` — prediction confidence sentence
- `attention_phrase(spotlight:, peripheral:, focused_domains:)` — attention focus description
- `memory_phrase(trace_count:, health:)` — memory system health sentence
- `reflection_phrase(health:, pending_adaptations:, recent_severity:)` — cognitive health sentence
- `overall_narrative(sections)` — joins non-empty section strings with `. ` into single paragraph

### `Helpers::Synthesizer` (module_function)
`narrate(tick_results:, cognitive_state:)` extracts relevant keys from both hashes and delegates to `Prose.*` methods. `infer_mood(tick_results, cognitive_state)` classifies mood from valence+arousal into `:energized`, `:content`, `:anxious`, `:subdued`, `:alert`, `:dormant`, or `:neutral`.

### `Helpers::Journal`
Rolling store capped at `MAX_JOURNAL_SIZE`. `append(entry)` adds to end, shifts oldest when full. `recent(limit:)`, `since(timestamp)`, `by_mood(mood)`, `stats` (mood counts, oldest/newest timestamps).

## LLM Enhancement

`Helpers::LlmEnhancer` provides optional LLM-generated narrative via `legion-llm`.

**System prompt theme**: Internal narrator for an autonomous AI agent. Translates raw cognitive metrics into flowing first-person introspection (3-5 sentences, present tense, varied structure).

| Method | Parameters | Returns |
|---|---|---|
| `available?` | — | `true` when `Legion::LLM.started?` |
| `narrate` | `sections_data:` | LLM-generated narrative string, or `nil` on failure |

`sections_data` is a hash of six cognitive domains (emotion, curiosity, prediction, memory, attention, reflection) assembled by the runner from `tick_results` and `cognitive_state`.

**Fallback**: When LLM is unavailable or returns nil, the existing `Helpers::Prose` label-based sentence concatenation pipeline is used unchanged.

**Source indicator**: `narrate` runner returns `source: :llm` in the result hash when LLM is used, `source:` key absent when falling back to `Prose`.

## Integration Points

- `narrate` consumes `tick_results` directly from `lex-tick` output
- `legion-llm` (optional): `LlmEnhancer` calls `Legion::LLM.chat` when started; fully skipped otherwise
- Emotion section reads from `tick_results[:emotional_evaluation]` (produced by `lex-emotion`)
- Curiosity section reads from `cognitive_state[:curiosity]` and `tick_results[:working_memory_integration]`
- Prediction section reads from `tick_results[:prediction_engine]` (produced by `lex-prediction`)
- Memory section reads from `cognitive_state[:memory]` and `tick_results[:memory_consolidation]`
- Reflection section reads from `cognitive_state[:reflection]` (produced by `lex-reflection`)
- `mood` output can feed `lex-emotion` as a secondary valence signal

## Development Notes

- `Synthesizer` and `Prose` are `module_function` modules — no state, no instantiation required
- `journal` in the runner is lazily memoized as `@journal` per runner instance
- Mood classification priority: energized/content (positive valence) > anxious/subdued (negative) > alert (high arousal) > dormant (low arousal) > neutral
- `gut_phrase` inspects `gut[:signal]` or `gut[:gut_signal]`; returns nil if absent or in neutral range
- LLM enhancement is always optional: `LlmEnhancer` rescues all `StandardError`, logs a warn, and returns nil — Prose fallback activates automatically
- `LlmEnhancer.available?` also rescues `StandardError` (returns false), so missing `legion-llm` gem never raises
