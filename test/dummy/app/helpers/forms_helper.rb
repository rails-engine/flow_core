# frozen_string_literal: true

module FormsHelper
  def smart_form_fields_path(form)
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
