# frozen_string_literal: true

require 'legion/extensions/narrator/helpers/constants'
require 'legion/extensions/narrator/helpers/prose'
require 'legion/extensions/narrator/helpers/journal'
require 'legion/extensions/narrator/helpers/synthesizer'
require 'legion/extensions/narrator/runners/narrator'

module Legion
  module Extensions
    module Narrator
      class Client
        include Runners::Narrator

        attr_reader :journal

        def initialize(journal: nil, **)
          @journal = journal || Helpers::Journal.new
        end
      end
    end
  end
end
