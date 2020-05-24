# frozen_string_literal: true

module FormKit
  class NestedForm < MetalForm
    belongs_to :attachable, polymorphic: true, touch: true
  end
end
