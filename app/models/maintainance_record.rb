class MaintenanceRecord < ApplicationRecord
  belongs_to :equipment

  validates :description, presence: true
  validates :performed_at, presence: true
end