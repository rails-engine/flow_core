# frozen_string_literal: true

module FormKit::Validations
  module Acceptance
    extend ActiveSupport::Concern

    prepended do
      attribute :acceptance, :boolean, default: false
    end

    def interpret_to(model, field_name, _accessibility, _options = {})
      super
      return unless acceptance

      model.validates field_name, acceptance: true
    end
  end
end
