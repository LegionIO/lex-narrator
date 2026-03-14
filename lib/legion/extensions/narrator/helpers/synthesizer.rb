# frozen_string_literal: true

module Legion
  module Extensions
    module Narrator
      module Helpers
        module Synthesizer
          module_function

          def narrate(tick_results: {}, cognitive_state: {})
            sections = build_sections(tick_results, cognitive_state)
            narrative = Prose.overall_narrative(sections.values)
            mood = infer_mood(tick_results, cognitive_state)

            {
              timestamp: Time.now.utc,
              narrative: narrative,
              sections:  sections,
              mood:      mood,
              tick_seq:  tick_results[:tick_seq] || cognitive_state[:tick_seq]
            }
          end

          def build_sections(tick_results, cognitive_state)
            {
              attention:  synthesize_attention(tick_results, cognitive_state),
              emotion:    synthesize_emotion(tick_results, cognitive_state),
              curiosity:  synthesize_curiosity(tick_results, cognitive_state),
              prediction: synthesize_prediction(tick_results, cognitive_state),
              memory:     synthesize_memory(tick_results, cognitive_state),
              reflection: synthesize_reflection(cognitive_state)
            }
          end

          def synthesize_attention(tick_results, cognitive_state)
            attention = tick_results[:sensory_processing] || {}
            focus = cognitive_state[:attention_status] || {}

            Prose.attention_phrase(
              spotlight:       attention[:spotlight] || 0,
              peripheral:      attention[:peripheral] || 0,
              focused_domains: extract_focused_domains(focus)
            )
          end

          def synthesize_emotion(tick_results, cognitive_state)
            valence_data = tick_results[:emotional_evaluation] || {}
            gut_data = tick_results[:gut_instinct] || cognitive_state[:gut] || {}

            Prose.emotion_phrase(
              valence: valence_data[:valence] || cognitive_state.dig(:emotion, :valence) || 0.0,
              arousal: valence_data[:arousal] || cognitive_state.dig(:emotion, :arousal) || 0.5,
              gut:     gut_data
            )
          end

          def synthesize_curiosity(tick_results, cognitive_state)
            curiosity_data = cognitive_state[:curiosity] || {}
            wonder_data = tick_results[:working_memory_integration] || {}

            Prose.curiosity_phrase(
              intensity:    curiosity_data[:intensity] || wonder_data[:curiosity_intensity] || 0.0,
              top_wonder:   extract_top_wonder(curiosity_data, wonder_data),
              wonder_count: curiosity_data[:active_count] || wonder_data[:active_wonders] || 0
            )
          end

          def synthesize_prediction(tick_results, cognitive_state)
            pred_data = tick_results[:prediction_engine] || {}
            pred_state = cognitive_state[:prediction] || {}

            Prose.prediction_phrase(
              confidence: pred_data[:confidence] || pred_state[:confidence] || 0.0,
              pending:    pred_state[:pending_count] || 0,
              mode:       pred_data[:mode] || pred_state[:mode]
            )
          end

          def synthesize_memory(tick_results, cognitive_state)
            memory_data = cognitive_state[:memory] || {}
            consol = tick_results[:memory_consolidation] || {}

            Prose.memory_phrase(
              trace_count: memory_data[:trace_count] || consol[:remaining] || 0,
              health:      memory_data[:health] || 1.0
            )
          end

          def synthesize_reflection(cognitive_state)
            ref_data = cognitive_state[:reflection] || {}

            Prose.reflection_phrase(
              health:              ref_data[:health] || 1.0,
              pending_adaptations: ref_data[:pending_adaptations] || 0,
              recent_severity:     ref_data[:recent_severity]
            )
          end

          def infer_mood(tick_results, cognitive_state)
            valence = tick_results.dig(:emotional_evaluation, :valence) ||
                      cognitive_state.dig(:emotion, :valence) || 0.0
            arousal = tick_results.dig(:emotional_evaluation, :arousal) ||
                      cognitive_state.dig(:emotion, :arousal) || 0.5

            classify_mood(valence, arousal)
          end

          def classify_mood(valence, arousal)
            if valence > 0.3 && arousal > 0.5 then :energized
            elsif valence > 0.3                   then :content
            elsif valence < -0.3 && arousal > 0.5 then :anxious
            elsif valence < -0.3                  then :subdued
            elsif arousal > 0.7                   then :alert
            elsif arousal < 0.2                   then :dormant
            else :neutral
            end
          end

          def extract_focused_domains(focus)
            manual = focus[:manual_focus]
            return [] unless manual.is_a?(Hash)

            manual.keys.map(&:to_s)
          end

          def extract_top_wonder(curiosity_data, wonder_data)
            curiosity_data[:top_question] || wonder_data[:top_question] ||
              (wonder_data[:top_wonder].is_a?(Hash) ? wonder_data[:top_wonder][:question] : nil)
          end
        end
      end
    end
  end
end
