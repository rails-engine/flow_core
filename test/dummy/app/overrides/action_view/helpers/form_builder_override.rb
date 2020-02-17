# frozen_string_literal: true

ActionView::Helpers::FormBuilder.class_eval do
  def error_message(method, tag: :div, ref_method: nil, escape: true, **options, &block)
    return if object.errors.empty?

    error = object.errors[method]&.first
    error ||= object.errors[ref_method]&.first if ref_method
    return unless error

    if block_given?
      @template.content_tag(tag, options, nil, escape, &block)
    else
      @template.content_tag(tag, error, options, escape)
    end
  end

  %i[text_field password_field file_field text_area
     color_field search_field telephone_field
     phone_field date_field time_field datetime_field
     datetime_local_field month_field week_field url_field
     email_field number_field range_field].each do |selector|
    alias_method :"_#{selector}", selector unless instance_methods(false).include?(:"_#{selector}")
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, **options)
        _#{selector} method, normalize_html_options(method, **options)
      end
    RUBY_EVAL
  end

  alias_method :_check_box, :check_box unless instance_methods(false).include?(:_check_box)
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    _check_box method, normalize_html_options(method, **options), checked_value, unchecked_value
  end

  alias_method :_radio_button, :radio_button unless instance_methods(false).include?(:_radio_button)
  def radio_button(method, tag_value, options = {})
    _radio_button method, tag_value, normalize_html_options(method, **options)
  end

  alias_method :_select, :select unless instance_methods(false).include?(:_select)
  def select(method, choices = nil, options = {}, html_options = {}, &block)
    _select method, choices, options, normalize_html_options(method, **html_options), &block
  end

  alias_method :_collection_select, :collection_select unless instance_methods(false).include?(:_collection_select)
  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    _collection_select method, collection, value_method, text_method, options, normalize_html_options(method, **html_options)
  end

  alias_method :_grouped_collection_select, :grouped_collection_select unless instance_methods(false).include?(:_grouped_collection_select)
  def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
    _grouped_collection_select method, collection, group_method, group_label_method, option_key_method, option_value_method, options, normalize_html_options(method, **html_options)
  end

  alias_method :_time_zone_select, :time_zone_select unless instance_methods(false).include?(:_time_zone_select)
  def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
    _time_zone_select method, priority_zones, options, normalize_html_options(method, **html_options)
  end

  # TODO: collection_check_boxes, collection_radio_buttons

  private

    def normalize_html_options(method, class_for_error: nil, ref_method: nil, **options)
      if @object&.errors&.any? && class_for_error.present?
        errors = @object.errors
        if errors.include?(method) || (ref_method.present? && errors.include?(ref_method.to_sym))
          return options.merge class: [options[:class], class_for_error].join(" ")
        end
      end

      options
    end
end
