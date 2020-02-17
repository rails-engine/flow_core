# frozen_string_literal: true

module ApplicationHelper
  def options_for_enum_select(klass, attribute, selected = nil)
    container = klass.public_send(attribute.to_s.pluralize).map do |k, v|
      v ||= k
      [klass.human_enum_value(attribute, k), v]
    end

    options_for_select(container, selected)
  end

  # See https://docs.gitlab.com/ee/development/ee_features.html#code-in-app-views
  def render_if_exists(partial, locals = {})
    render(partial, locals) if partial_exists?(partial)
  end

  def partial_exists?(partial)
    lookup_context.exists?(partial, [], true)
  end

  def template_exists?(template)
    lookup_context.exists?(template, [], false)
  end

  # Check if a particular controller is the current one
  #
  # args - One or more controller names to check (using path notation when inside namespaces)
  #
  # Examples
  #
  #   # On TreeController
  #   current_controller?(:tree)           # => true
  #   current_controller?(:commits)        # => false
  #   current_controller?(:commits, :tree) # => true
  #
  #   # On Admin::ApplicationController
  #   current_controller?(:application)         # => true
  #   current_controller?('admin/application')  # => true
  #   current_controller?('gitlab/application') # => false
  def current_controller?(*args)
    args.any? do |v|
      v.to_s.downcase == controller.controller_name || v.to_s.downcase == controller.controller_path
    end
  end

  # Check if current controller is under the given namespace
  #
  # namespace - One or more controller names to check (using path notation when inside namespaces)
  #
  # Examples
  #
  #   # On Admin::ApplicationController
  #   current_namespace?(:application)         # => false
  #   current_namespace?('admin/application')  # => true
  #   current_namespace?('gitlab/application') # => false
  def current_namespace?(namespace)
    controller.controller_path.start_with? namespace.to_s.downcase
  end

  # Check if a particular action is the current one
  #
  # args - One or more action names to check
  #
  # Examples
  #
  #   # On Projects#new
  #   current_action?(:new)           # => true
  #   current_action?(:create)        # => false
  #   current_action?(:new, :create)  # => true
  def current_action?(*args)
    args.any? { |v| v.to_s.downcase == action_name }
  end

  # Returns active css class when condition returns true
  # otherwise returns nil.
  #
  # Example:
  #   %li{ class: active_when(params[:filter] == '1') }
  def active_when(condition)
    "active" if condition
  end
end
