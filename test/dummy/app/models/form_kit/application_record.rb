# frozen_string_literal: true

module FormKit
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true

    include ModelKit::ActsAsDefaultValue
    include ModelKit::EnumAttributeLocalizable
  end
end
