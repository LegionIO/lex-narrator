# frozen_string_literal: true

module Legion
  module Extensions
    module Narrator
      module Helpers
        module Constants
          # Maximum entries in the narrative journal
          MAX_JOURNAL_SIZE = 500

          # Narrative generation modes
          MODES = %i[mechanical enhanced].freeze

          # Default sections in a narrative entry
          SECTIONS = %i[
            attention emotion curiosity prediction
            memory reflection identity overall
          ].freeze

          # Emotional dimension labels for prose generation
          EMOTION_LABELS = {
            high_positive: 'engaged and optimistic',
            low_positive:  'calm and steady',
            neutral:       'emotionally neutral',
            low_negative:  'slightly uneasy',
            high_negative: 'distressed'
          }.freeze

          # Arousal labels
          AROUSAL_LABELS = {
            high:    'highly alert',
            medium:  'moderately attentive',
            low:     'calm and measured',
            dormant: 'in a low-activity state'
          }.freeze

          # Curiosity intensity labels
          CURIOSITY_LABELS = {
            high:   'deeply curious',
            medium: 'moderately curious',
            low:    'mildly interested',
            none:   'not particularly curious about anything'
          }.freeze

          # Prediction confidence labels
          CONFIDENCE_LABELS = {
            high:   'confident in my predictions',
            medium: 'moderately confident',
            low:    'uncertain about outcomes',
            none:   'lacking predictive context'
          }.freeze

          # Cognitive health labels
          HEALTH_LABELS = {
            excellent: 'operating at full capacity',
            good:      'functioning well overall',
            fair:      'showing some strain',
            poor:      'experiencing significant cognitive difficulty',
            critical:  'in cognitive distress'
          }.freeze
        end
      end
    end
  end
end
