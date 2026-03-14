# frozen_string_literal: true

module Legion
  module Extensions
    module Narrator
      module Runners
        module Narrator
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def narrate(tick_results: {}, cognitive_state: {}, **)
            entry = Helpers::Synthesizer.narrate(tick_results: tick_results, cognitive_state: cognitive_state)
            journal.append(entry)

            Legion::Logging.debug "[narrator] mood=#{entry[:mood]} sections=#{entry[:sections].keys.size}"

            {
              narrative: entry[:narrative],
              mood:      entry[:mood],
              timestamp: entry[:timestamp],
              sections:  entry[:sections]
            }
          end

          def recent_entries(limit: 10, **)
            entries = journal.recent(limit: limit)
            {
              entries: entries.map { |e| format_entry(e) },
              count:   entries.size,
              total:   journal.size
            }
          end

          def entries_since(since:, **)
            timestamp = since.is_a?(Time) ? since : Time.parse(since.to_s)
            entries = journal.since(timestamp)
            {
              entries: entries.map { |e| format_entry(e) },
              count:   entries.size,
              since:   timestamp
            }
          end

          def mood_history(mood: nil, limit: 20, **)
            entries = mood ? journal.by_mood(mood.to_sym) : journal.entries
            recent = entries.last(limit)
            {
              entries: recent.map { |e| { timestamp: e[:timestamp], mood: e[:mood], narrative: e[:narrative] } },
              count:   recent.size,
              mood:    mood
            }
          end

          def current_narrative(**)
            entry = journal.entries.last
            return { narrative: 'No cognitive activity recorded yet.', mood: :dormant } unless entry

            {
              narrative:   entry[:narrative],
              mood:        entry[:mood],
              timestamp:   entry[:timestamp],
              age_seconds: (Time.now.utc - entry[:timestamp]).round(1)
            }
          end

          def narrator_stats(**)
            stats = journal.stats
            mood_summary = stats[:moods] || {}
            dominant_mood = mood_summary.max_by { |_, count| count }&.first

            {
              journal_size:  journal.size,
              capacity:      Helpers::Constants::MAX_JOURNAL_SIZE,
              dominant_mood: dominant_mood,
              mood_counts:   mood_summary,
              oldest:        stats[:oldest],
              newest:        stats[:newest]
            }
          end

          private

          def journal
            @journal ||= Helpers::Journal.new
          end

          def format_entry(entry)
            {
              timestamp: entry[:timestamp],
              narrative: entry[:narrative],
              mood:      entry[:mood],
              sections:  entry[:sections]
            }
          end
        end
      end
    end
  end
end
