# frozen_string_literal: true

module Legion
  module Extensions
    module Narrator
      module Helpers
        module Prose
          module_function

          def emotion_phrase(valence: 0.0, arousal: 0.5, gut: nil)
            emotion_label = emotion_label_for(valence)
            arousal_label = arousal_label_for(arousal)
            base = "I am #{arousal_label} and #{emotion_label}"
            gut_note = gut_phrase(gut)
            gut_note ? "#{base}. #{gut_note}" : base
          end

          def curiosity_phrase(intensity: 0.0, top_wonder: nil, wonder_count: 0)
            label = curiosity_label_for(intensity)
            base = "I am #{label}"
            if top_wonder && wonder_count.positive?
              "#{base}, with #{wonder_count} open #{'question' if wonder_count == 1}#{'questions' if wonder_count != 1}. " \
                "Most pressing: \"#{top_wonder}\""
            else
              base
            end
          end

          def prediction_phrase(confidence: 0.0, pending: 0, mode: nil)
            label = confidence_label_for(confidence)
            base = "I am #{label}"
            base += " (#{mode} reasoning)" if mode
            base += ", with #{pending} pending predictions" if pending.positive?
            base
          end

          def attention_phrase(spotlight: 0, peripheral: 0, focused_domains: [])
            parts = ["#{spotlight} signals in spotlight focus, #{peripheral} in peripheral awareness"]
            parts << "manually focused on: #{focused_domains.join(', ')}" if focused_domains.any?
            parts.join('. ')
          end

          def memory_phrase(trace_count: 0, health: 1.0)
            health_label = health_label_for(health)
            "Memory system #{health_label} with #{trace_count} active traces"
          end

          def reflection_phrase(health: 1.0, pending_adaptations: 0, recent_severity: nil)
            label = health_label_for(health)
            base = "Cognitive health: #{label}"
            base += ". #{pending_adaptations} pending adaptation recommendations" if pending_adaptations.positive?
            base += ". Most recent concern: #{recent_severity}" if recent_severity
            base
          end

          def overall_narrative(sections)
            "#{sections.compact.reject(&:empty?).join('. ')}."
          end

          def gut_phrase(gut)
            return nil unless gut.is_a?(Hash)

            signal = gut[:signal] || gut[:gut_signal]
            return nil unless signal

            if signal > 0.3
              'My gut says something important is happening'
            elsif signal < -0.3
              'I have an uneasy feeling about the current situation'
            end
          end

          def emotion_label_for(valence)
            if valence > 0.5      then Constants::EMOTION_LABELS[:high_positive]
            elsif valence > 0.1   then Constants::EMOTION_LABELS[:low_positive]
            elsif valence > -0.1  then Constants::EMOTION_LABELS[:neutral]
            elsif valence > -0.5  then Constants::EMOTION_LABELS[:low_negative]
            else Constants::EMOTION_LABELS[:high_negative]
            end
          end

          def arousal_label_for(arousal)
            if arousal > 0.7    then Constants::AROUSAL_LABELS[:high]
            elsif arousal > 0.4 then Constants::AROUSAL_LABELS[:medium]
            elsif arousal > 0.1 then Constants::AROUSAL_LABELS[:low]
            else Constants::AROUSAL_LABELS[:dormant]
            end
          end

          def curiosity_label_for(intensity)
            if intensity > 0.7    then Constants::CURIOSITY_LABELS[:high]
            elsif intensity > 0.4 then Constants::CURIOSITY_LABELS[:medium]
            elsif intensity > 0.1 then Constants::CURIOSITY_LABELS[:low]
            else Constants::CURIOSITY_LABELS[:none]
            end
          end

          def confidence_label_for(confidence)
            if confidence > 0.7    then Constants::CONFIDENCE_LABELS[:high]
            elsif confidence > 0.4 then Constants::CONFIDENCE_LABELS[:medium]
            elsif confidence > 0.1 then Constants::CONFIDENCE_LABELS[:low]
            else Constants::CONFIDENCE_LABELS[:none]
            end
          end

          def health_label_for(health)
            if health > 0.9    then Constants::HEALTH_LABELS[:excellent]
            elsif health > 0.7 then Constants::HEALTH_LABELS[:good]
            elsif health > 0.5 then Constants::HEALTH_LABELS[:fair]
            elsif health > 0.3 then Constants::HEALTH_LABELS[:poor]
            else Constants::HEALTH_LABELS[:critical]
            end
          end
        end
      end
    end
  end
end
