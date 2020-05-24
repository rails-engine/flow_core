# frozen_string_literal: true

class FormKit::Field
  module Fakable
    extend ActiveSupport::Concern

    module ClassMethods
      def configure_fake_options_to(_field); end
    end
  end
end
