# frozen_string_literal: true

module BreadcrumbsHelper
  def breadcrumbs
    @_breadcrumbs ||= []
  end

  def add_to_breadcrumbs(text, link = nil)
    breadcrumbs.push(
      text: text,
      link: link
    )
  end

  def render_breadcrumbs
    return unless breadcrumbs.any?

    render "layouts/breadcrumb"
  end
end
