class CalculateRestaurantRating
  def self.call(restaurant)
    new(restaurant).call
  end

  def initialize(restaurant)
    @restaurant = restaurant
  end

  def call
    return 0.0 if restaurant.reviews.empty?

    average_rating = restaurant.reviews.average(:rating).to_f
    average_rating.round(2)
  end

  private

  attr_reader :restaurant
end
