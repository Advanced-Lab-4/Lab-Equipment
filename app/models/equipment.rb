class Equipment < ApplicationRecord
  belongs_to :category
  has_many :maintenance_records, dependent: :destroy

  validates :name, presence: true, length: { minimum: 3 }, format: { with: /\A[a-zA-Z\s]+\z/, message: "must contain at least one letter" }
  validates :serial_number, presence: true, uniqueness: true, format: { with: /\A[A-Z]{3}-\d{3}\z/, message: "must match format XXX-NNN" }
  validates :status, presence: true, inclusion: { in: %w[available in_use maintenance] }
end
