# Changelog

## [0.1.1] - 2026-03-14

### Added
- Optional LLM enhancement via Helpers::LlmEnhancer — `narrate(sections_data:)` generates full narrative prose from section data (emotion, curiosity, prediction, memory, attention, reflection), replacing the Mad-Libs `Prose.*` pipeline when `Legion::LLM` is available. Falls back to mechanical pipeline when LLM is unavailable or returns nil. Runner returns `source: :llm` in the result hash when LLM is used.

## [0.1.0] - 2026-03-13

### Added
- Initial release
