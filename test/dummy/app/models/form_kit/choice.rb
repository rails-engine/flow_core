# frozen_string_literal: true

module FormKit
  class Choice < ApplicationRecord
    self.table_name = "form_kit_choices"

    belongs_to :form, class_name: "FormKit::MetalForm"
    belongs_to :field

    validates :label,
              presence: true

    acts_as_list scope: [:field_id]

    before_validation do
      self.form ||= field&.form if new_record?
    end
  end
end
