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

            if Helpers::LlmEnhancer.available?
              sections_data = build_llm_sections_data(tick_results, cognitive_state, entry)
              llm_result = Helpers::LlmEnhancer.narrate(sections_data: sections_data)
              if llm_result
                entry = entry.merge(narrative: llm_result, source: :llm)
                journal.append(entry)
                Legion::Logging.debug "[narrator] mood=#{entry[:mood]} source=llm sections=#{entry[:sections].keys.size}"
                return {
                  narrative: entry[:narrative],
                  mood:      entry[:mood],
                  timestamp: entry[:timestamp],
                  sections:  entry[:sections],
                  source:    :llm
                }
              end
            end

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

          def build_llm_sections_data(tick_results, cognitive_state, entry)
            {
              emotion:    llm_emotion_data(tick_results, cognitive_state),
              curiosity:  llm_curiosity_data(tick_results, cognitive_state),
              prediction: llm_prediction_data(tick_results, cognitive_state),
              memory:     llm_memory_data(tick_results, cognitive_state),
              attention:  llm_attention_data(tick_results, cognitive_state),
              reflection: llm_reflection_data(cognitive_state),
              mood:       entry[:mood]
            }
          end

          def llm_emotion_data(tick_results, cognitive_state)
            v = tick_results[:emotional_evaluation] || {}
            g = tick_results[:gut_instinct] || cognitive_state[:gut] || {}
            {
              valence: v[:valence] || cognitive_state.dig(:emotion, :valence) || 0.0,
              arousal: v[:arousal] || cognitive_state.dig(:emotion, :arousal) || 0.5,
              gut:     g[:signal] || g[:gut_signal]
            }
          end

          def llm_curiosity_data(tick_results, cognitive_state)
            c = cognitive_state[:curiosity] || {}
            w = tick_results[:working_memory_integration] || {}
            {
              intensity:    c[:intensity] || w[:curiosity_intensity] || 0.0,
              wonder_count: c[:active_count] || w[:active_wonders] || 0,
              top_wonder:   c[:top_question] || w[:top_question]
            }
          end

          def llm_prediction_data(tick_results, cognitive_state)
            p = tick_results[:prediction_engine] || {}
            s = cognitive_state[:prediction] || {}
            {
              confidence: p[:confidence] || s[:confidence] || 0.0,
              pending:    s[:pending_count] || 0,
              mode:       p[:mode] || s[:mode]
            }
          end

          def llm_memory_data(tick_results, cognitive_state)
            m = cognitive_state[:memory] || {}
            c = tick_results[:memory_consolidation] || {}
            {
              trace_count: m[:trace_count] || c[:remaining] || 0,
              health:      m[:health] || 1.0
            }
          end

          def llm_attention_data(tick_results, cognitive_state)
            a = tick_results[:sensory_processing] || {}
            f = cognitive_state[:attention_status] || {}
            {
              spotlight:       a[:spotlight] || 0,
              peripheral:      a[:peripheral] || 0,
              focused_domains: extract_focused_domains_for_llm(f)
            }
          end

          def llm_reflection_data(cognitive_state)
            r = cognitive_state[:reflection] || {}
            {
              health:              r[:health] || 1.0,
              pending_adaptations: r[:pending_adaptations] || 0
            }
          end

          def extract_focused_domains_for_llm(focus)
            manual = focus[:manual_focus]
            return [] unless manual.is_a?(Hash)

            manual.keys.map(&:to_s)
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
