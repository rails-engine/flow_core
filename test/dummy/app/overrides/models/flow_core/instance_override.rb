# frozen_string_literal: true

FlowCore::Instance.class_eval do
  belongs_to :creator, class_name: "User", optional: true
end
