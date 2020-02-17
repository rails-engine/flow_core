# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :task, class_name: "FlowCore::Task"
end
