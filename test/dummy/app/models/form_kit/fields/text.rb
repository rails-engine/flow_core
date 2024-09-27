# frozen_string_literal: true

module FormKit::Fields
  class Text < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: Options

    def stored_type
      :string
    end
  end
end
