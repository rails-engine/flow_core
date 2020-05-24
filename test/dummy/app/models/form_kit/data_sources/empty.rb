# frozen_string_literal: true

module FormKit::DataSources
  class Empty < FormKit::DataSource
    def foreign_field_name_suffix
      ""
    end

    def foreign_field_name(field_name)
      field_name
    end

    def text_method
      nil
    end

    def interpret_to(_model, _field_name, _accessibility, _options = {}); end

    class << self
      def scoped_records(*)
        FormKit::ApplicationRecord.none
      end
    end
  end
end
