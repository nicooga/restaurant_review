class RestaurantIndexQuery
  def self.call(params = {})
    new(params).call
  end

  def initialize(params = {})
    @params = params || {}
    @filters = @params[:filters] || {}
    @sort = @params[:sort] || {}
  end

  def call
    restaurants = Restaurant.all
    restaurants = apply_filters(restaurants)
    restaurants = apply_sorting(restaurants)
    restaurants
  end

  private

  attr_reader :params, :filters, :sort

  def apply_filters(restaurants)
    restaurants = restaurants.by_name(filters[:name]) if filters[:name].present?
    restaurants = restaurants.by_cuisine(filters[:cuisine_type]) if filters[:cuisine_type].present?
    restaurants = restaurants.by_max_price(filters[:max_price]) if filters[:max_price].present?
    restaurants = restaurants.by_min_rating(filters[:min_rating]) if filters[:min_rating].present?
    restaurants
  end

  def apply_sorting(restaurants)
    sort_direction = sort[:direction] == 'desc' ? :desc : :asc

    case sort[:by]
    when 'name'
      restaurants.order(name: sort_direction)
    when 'rating'
      restaurants.order(calculated_rating: sort_direction)
    when 'price_range'
      restaurants.order(price_range: sort_direction)
    when 'created_at'
      restaurants.order(created_at: sort_direction)
    else
      # Default sort: highest rated first, then by name alphabetically
      restaurants.order(calculated_rating: :desc, name: :asc)
    end
  end
end
