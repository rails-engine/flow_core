# frozen_string_literal: true

module FlowCore
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
