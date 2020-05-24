# frozen_string_literal: true

module FormKit
  class FieldOptions < SerializableModel::Base
    def interpret_to(_model, _field_name, _accessibility, _options = {}); end
  end
end
