# frozen_string_literal: true

class FormKit::Fields::MultipleSelect
  module Fakable
    extend ActiveSupport::Concern

    module ClassMethods
      def configure_fake_options_to(field)
        field.choices.build label: Faker::Artist.name
        field.choices.build label: Faker::Artist.name
        field.choices.build label: Faker::Artist.name
        field.choices.build label: Faker::Artist.name
      end
    end
  end
end
