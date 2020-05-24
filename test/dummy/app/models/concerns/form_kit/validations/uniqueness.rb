# frozen_string_literal: true

module FormKit::Validations
  module Uniqueness
    extend ActiveSupport::Concern

    prepended do
      attribute :uniqueness, :boolean, default: false
    end

    def interpret_to(model, field_name, _accessibility, _options = {})
      super
      return unless uniqueness

      # TODO:
      # model.validates field_name, presence: true
    end
  end
end
