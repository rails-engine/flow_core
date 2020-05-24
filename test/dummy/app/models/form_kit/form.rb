# frozen_string_literal: true

module FormKit
  class Form < MetalForm
    validates :name,
              presence: true

    include Fakable
  end
end
