class CreateReview
  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
    @user = params[:user]
    @restaurant = params[:restaurant]
    @rating = params[:rating]
    @comment = params[:comment]
  end

  def call
    ActiveRecord::Base.transaction do
      create_review
      recalculate_restaurant_rating
      @review
    end
  end

  private

  attr_reader :params, :user, :restaurant, :rating, :comment, :review

  def create_review
    @review = Review.create!(
      user: user,
      restaurant: restaurant,
      rating: rating,
      comment: comment
    )
  end

  def recalculate_restaurant_rating
    new_rating = CalculateRestaurantRating.call(restaurant)
    restaurant.update!(calculated_rating: new_rating)
  end
end
