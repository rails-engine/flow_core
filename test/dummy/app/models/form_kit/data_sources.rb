# frozen_string_literal: true

module FormKit::DataSources
  %w[empty].each do |type|
    require_dependency "form_kit/data_sources/#{type}"
  end
end
