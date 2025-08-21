class RestaurantsController < ApplicationController
  allow_unauthenticated_access only: [:index, :show, :reviews]

  # GET /restaurants
  def index
    restaurants = SearchRestaurants.call(search_params)
    render json: RestaurantBlueprint.render(restaurants)
  end

  # GET /restaurants/:id
  def show
    restaurant = Restaurant.find(params[:id])
    render json: RestaurantBlueprint.render(restaurant)
  end

  # GET /restaurants/:id/reviews
  def reviews
    restaurant = Restaurant.find(params[:id])
    reviews = restaurant.reviews.recent.includes(:user)
    render json: ReviewBlueprint.render(reviews, view: :detail)
  end

  # POST /restaurants/:id/reviews
  def create_review
    restaurant = Restaurant.find(params[:id])

    create_review_params = {
      user: Current.user,
      restaurant: restaurant,
      rating: params[:rating],
      comment: params[:comment]
    }

    review = CreateReview.call(create_review_params)

    render json: ReviewBlueprint.render(review, view: :detail), status: :created
  end

  private

  def search_params
    return {} unless params.key?(:filters) || params.key?(:sort)

    {
      filters: filter_params,
      sort: sort_params
    }
  end

  def filter_params
    return {} unless params[:filters]

    params.require(:filters).permit(:name, :cuisine_type, :max_price, :min_rating)
  end

  def sort_params
    return {} unless params[:sort]

    params.require(:sort).permit(:by, :direction)
  end
end
