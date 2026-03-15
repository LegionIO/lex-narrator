# frozen_string_literal: true

require 'legion/extensions/narrator/version'
require 'legion/extensions/narrator/helpers/constants'
require 'legion/extensions/narrator/helpers/prose'
require 'legion/extensions/narrator/helpers/journal'
require 'legion/extensions/narrator/helpers/synthesizer'
require 'legion/extensions/narrator/helpers/llm_enhancer'
require 'legion/extensions/narrator/runners/narrator'
require 'legion/extensions/narrator/client'

module Legion
  module Extensions
    module Narrator
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
