# frozen_string_literal: true

module FormKit::Validations
  module Confirmation
    extend ActiveSupport::Concern

    prepended do
      attribute :confirmation, :boolean, default: false
    end

    def interpret_to(model, field_name, _accessibility, _options = {})
      super
      return unless confirmation

      model.validates field_name, confirmation: true
    end
  end
end
