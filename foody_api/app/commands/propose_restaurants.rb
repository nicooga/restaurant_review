class SortRestaurantsByUserScore
    def call(params)
        new(params).call
    end

    def initialize(params)
        @resturants = params[:restaurants]
        @users = params[:users]
    end

    def call
        @resturants.sort_by do |restaurant|
            agg_score =
                cuisine_score(restaurant)
                + distance_score(restaurant)
                + 2 * review_score(restaurant)

            agg_score / 4
        end
    end

    # Returns a number in in the interval [0, 1]
    def cuisine_score(restaurant)
        cuisine_score_raw = @users.map do |user|
            return user.cuisine_preferences[restaurant.cuisine] / 5
        end
        total = cuisine_score_raw.reduce(0) { |sum, score| sum + score }
        total / restaurant.length
    end

    def review_score(restaurant)
        return restaurant.calculated_rating / 5
    end

    def user_price_score(user)
     # Get user's preferred price range and restaurant's price range
     user_price = user.meal_preferences[:preferred_price_range] || 2 # Default to moderate
     restaurant_price = restaurant.price_range

     # Apply the specified price scoring rules
       if user_price == restaurant_price
            # Best scenario - exact match
            return 1.0
         elsif restaurant_price == user_price + 1
           # Restaurant price 1 level above - so so
           return 0.75
         elsif restaurant_price == user_price + 2
           # Restaurant price 2 levels above - bad
           return 0.5
         elsif restaurant_price < user_price
           # Restaurant price below expected - good
           return 1.0
       else
      # More than 2 levels above - worst case
        return 0.0
      end
    end
end
