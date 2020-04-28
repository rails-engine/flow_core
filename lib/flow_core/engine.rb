# frozen_string_literal: true

module FlowCore
  class Engine < ::Rails::Engine
    initializer "flow_core.load_default_i18n" do
      ActiveSupport.on_load(:i18n) do
        I18n.load_path << File.expand_path("locale/en.yml", __dir__)
      end
    end
  end
end
