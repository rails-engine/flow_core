# frozen_string_literal: true

module FormKit::Fields
  class Text < FormKit::Field
    serialize :validations, Validations
    serialize :options, Options

    def stored_type
      :string
    end
  end
end
