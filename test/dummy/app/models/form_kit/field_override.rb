# frozen_string_literal: true

module FormKit
  class FieldOverride < FormKit::ApplicationRecord
    self.table_name = "form_kit_field_overrides"

    belongs_to :form_override, class_name: "FormKit::FormOverride"
    belongs_to :field, class_name: "FormKit::Field", foreign_key: "field_id"

    enum accessibility: { read_and_write: 0, readonly: 1, hidden: 2 },
         _prefix: :access

    validates :accessibility,
              presence: true
  end
end
