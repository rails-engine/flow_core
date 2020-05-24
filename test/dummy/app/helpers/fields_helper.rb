# frozen_string_literal: true

module FieldsHelper
  def options_for_field_types(form, selected: nil)
    fields = FormKit::Field.descendants
    if form.attachable_id.present?
      fields -= [FormKit::Fields::NestedForm, FormKit::Fields::MultipleNestedForm]
    end

    options_for_select(fields.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def options_for_data_source_types(selected: nil)
    options_for_select(FormKit::DataSource.descendants.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def field_label(form, field_name:)
    field_name = field_name.to_s.split(".").first.to_sym

    form.fields.find do |field|
      field.name == field_name
    end&.label
  end

  def fields_path(field)
    form = field.form

    case form
    when FormKit::Form
      form_fields_path(form)
    when FormKit::NestedForm
      nested_form_fields_path(form)
    else
      raise "Unknown form: #{form.class}"
    end
  end
end
