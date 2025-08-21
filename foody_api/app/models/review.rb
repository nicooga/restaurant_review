class Review < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :restaurant

  # Validations
  validates :rating, presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 5
            }
  validates :comment, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :restaurant_id, message: "can only review a restaurant once" }

  # Scopes
  scope :by_rating, ->(rating) { where(rating: rating) if rating.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :highest_rated, -> { order(rating: :desc, created_at: :desc) }
  scope :lowest_rated, -> { order(rating: :asc, created_at: :desc) }
end
