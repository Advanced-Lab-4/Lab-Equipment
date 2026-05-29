class Category < ApplicationRecord
  has_many :equipment, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }
end
