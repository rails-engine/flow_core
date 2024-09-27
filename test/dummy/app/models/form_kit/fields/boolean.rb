# frozen_string_literal: true

module FormKit::Fields
  class Boolean < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: FormKit::NonConfigurable

    def stored_type
      :boolean
    end
  end
end
