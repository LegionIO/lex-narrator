# frozen_string_literal: true

module Legion
  module Extensions
    module Narrator
      module Helpers
        class Journal
          attr_reader :entries

          def initialize
            @entries = []
          end

          def append(entry)
            @entries << entry
            trim_to_capacity
            entry
          end

          def recent(limit: 10)
            @entries.last(limit)
          end

          def since(timestamp)
            @entries.select { |e| e[:timestamp] >= timestamp }
          end

          def by_mood(mood)
            @entries.select { |e| e[:mood] == mood }
          end

          def size
            @entries.size
          end

          def clear
            @entries.clear
          end

          def stats
            return { total: 0, moods: {} } if @entries.empty?

            mood_counts = @entries.each_with_object(Hash.new(0)) { |e, h| h[e[:mood]] += 1 }
            {
              total:    @entries.size,
              moods:    mood_counts,
              oldest:   @entries.first[:timestamp],
              newest:   @entries.last[:timestamp],
              capacity: Constants::MAX_JOURNAL_SIZE
            }
          end

          private

          def trim_to_capacity
            @entries.shift(@entries.size - Constants::MAX_JOURNAL_SIZE) if @entries.size > Constants::MAX_JOURNAL_SIZE
          end
        end
      end
    end
  end
end
