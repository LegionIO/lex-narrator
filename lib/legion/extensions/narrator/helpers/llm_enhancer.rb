# frozen_string_literal: true

module Legion
  module Extensions
    module Narrator
      module Helpers
        module LlmEnhancer
          SYSTEM_PROMPT = <<~PROMPT
            You are the internal narrator for an autonomous AI agent built on LegionIO.
            You translate raw cognitive metrics into a flowing first-person internal monologue.
            Write 3-5 sentences that feel like genuine introspection, not a report.
            Vary your sentence structure. Use present tense. Be concise and vivid.
          PROMPT

          module_function

          def available?
            !!(defined?(Legion::LLM) && Legion::LLM.respond_to?(:started?) && Legion::LLM.started?)
          rescue StandardError
            false
          end

          def narrate(sections_data:)
            prompt = build_narrate_prompt(sections_data)
            response = llm_ask(prompt)
            parse_narrate_response(response)
          rescue StandardError => e
            Legion::Logging.warn "[narrator:llm] narrate failed: #{e.message}"
            nil
          end

          # --- Private helpers ---

          def llm_ask(prompt)
            chat = Legion::LLM.chat
            chat.with_instructions(SYSTEM_PROMPT)
            chat.ask(prompt)
          end
          private_class_method :llm_ask

          def build_narrate_prompt(sections_data)
            parts = [
              'Generate a first-person internal monologue based on the following cognitive state:',
              '',
              emotion_section(sections_data[:emotion] || {}),
              curiosity_section(sections_data[:curiosity] || {}),
              prediction_section(sections_data[:prediction] || {}),
              memory_section(sections_data[:memory] || {}),
              attention_section(sections_data[:attention] || {}),
              reflection_section(sections_data[:reflection] || {}),
              '',
              "Write a 3-5 sentence first-person narrative. Do not mention numbers directly \u2014 translate them into felt experience."
            ]
            parts.join("\n")
          end

          def emotion_section(emo)
            "EMOTION:\n- Valence: #{emo[:valence] || 0.0}\n- Arousal: #{emo[:arousal] || 0.5}\n- Gut signal: #{emo[:gut] || 'none'}"
          end

          def curiosity_section(cur)
            "CURIOSITY:\n- Intensity: #{cur[:intensity] || 0.0}\n- Active questions: #{cur[:wonder_count] || 0}\n- Top question: #{cur[:top_wonder] || 'none'}"
          end

          def prediction_section(pred)
            "PREDICTION:\n- Confidence: #{pred[:confidence] || 0.0}\n- Pending: #{pred[:pending] || 0}\n- Mode: #{pred[:mode] || 'unknown'}"
          end

          def memory_section(mem)
            "MEMORY:\n- Active traces: #{mem[:trace_count] || 0}\n- Health: #{mem[:health] || 1.0}"
          end

          def attention_section(att)
            domains = Array(att[:focused_domains]).join(', ')
            domains = 'none' if domains.empty?
            "ATTENTION:\n- Spotlight: #{att[:spotlight] || 0}\n- Peripheral: #{att[:peripheral] || 0}\n- Focused: #{domains}"
          end

          def reflection_section(ref)
            "REFLECTION:\n- Cognitive health: #{ref[:health] || 1.0}\n- Pending adaptations: #{ref[:pending_adaptations] || 0}"
          end

          def parse_narrate_response(response)
            return nil unless response&.content

            response.content.strip
          end

          private_class_method :build_narrate_prompt
          private_class_method :emotion_section
          private_class_method :curiosity_section
          private_class_method :prediction_section
          private_class_method :memory_section
          private_class_method :attention_section
          private_class_method :reflection_section
          private_class_method :parse_narrate_response
        end
      end
    end
  end
end
