require 'rails_helper'

RSpec.describe CalculateRestaurantRating, type: :lib do
  let(:restaurant) { create(:restaurant, calculated_rating: 0.0) }

  describe '.call' do
    context 'with no reviews' do
      it 'returns 0.0 for restaurant with no reviews' do
        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(0.0)
      end
    end

    context 'with single review' do
      it 'returns the rating of single review' do
        create(:review, restaurant: restaurant, rating: 4)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(4.0)
      end

      it 'returns 1.0 for single 1-star review' do
        create(:review, restaurant: restaurant, rating: 1)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(1.0)
      end

      it 'returns 5.0 for single 5-star review' do
        create(:review, restaurant: restaurant, rating: 5)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(5.0)
      end
    end

    context 'with multiple reviews' do
      it 'calculates average of two reviews' do
        create(:review, restaurant: restaurant, rating: 5)
        create(:review, restaurant: restaurant, rating: 3)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(4.0) # (5 + 3) / 2 = 4.0
      end

      it 'calculates average of three reviews' do
        create(:review, restaurant: restaurant, rating: 5)
        create(:review, restaurant: restaurant, rating: 4)
        create(:review, restaurant: restaurant, rating: 3)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(4.0) # (5 + 4 + 3) / 3 = 4.0
      end

      it 'rounds to 2 decimal places' do
        create(:review, restaurant: restaurant, rating: 5)
        create(:review, restaurant: restaurant, rating: 4)
        create(:review, restaurant: restaurant, rating: 4)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(4.33) # (5 + 4 + 4) / 3 = 4.33333... -> 4.33
      end

      it 'handles uneven averages' do
        create(:review, restaurant: restaurant, rating: 1)
        create(:review, restaurant: restaurant, rating: 2)
        create(:review, restaurant: restaurant, rating: 5)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(2.67) # (1 + 2 + 5) / 3 = 2.66666... -> 2.67
      end

      it 'calculates average of many reviews' do
        # Create 10 reviews with rating 4
        10.times { create(:review, restaurant: restaurant, rating: 4) }
        # Create 5 reviews with rating 2
        5.times { create(:review, restaurant: restaurant, rating: 2) }

        result = CalculateRestaurantRating.call(restaurant)
        # (4*10 + 2*5) / 15 = (40 + 10) / 15 = 50/15 = 3.33333... -> 3.33
        expect(result).to eq(3.33)
      end
    end

    context 'with different restaurant scenarios' do
      let(:restaurant2) { create(:restaurant) }

      it 'calculates rating for different restaurants independently' do
        # Restaurant 1: 4-star average
        create(:review, restaurant: restaurant, rating: 5)
        create(:review, restaurant: restaurant, rating: 3)

        # Restaurant 2: 2-star average
        create(:review, restaurant: restaurant2, rating: 1)
        create(:review, restaurant: restaurant2, rating: 3)

        result1 = CalculateRestaurantRating.call(restaurant)
        result2 = CalculateRestaurantRating.call(restaurant2)

        expect(result1).to eq(4.0)
        expect(result2).to eq(2.0)
      end

      it 'ignores reviews from other restaurants' do
        create(:review, restaurant: restaurant, rating: 5)
        create(:review, restaurant: restaurant2, rating: 1) # Different restaurant

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(5.0) # Only counts the 5-star review for this restaurant
      end
    end

    context 'precision and edge cases' do
      it 'returns exact decimal when possible' do
        create(:review, restaurant: restaurant, rating: 3)
        create(:review, restaurant: restaurant, rating: 4)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(3.5) # (3 + 4) / 2 = 3.5
      end

      it 'handles very small decimal differences' do
        # Create a scenario that results in a repeating decimal
        create(:review, restaurant: restaurant, rating: 1)
        create(:review, restaurant: restaurant, rating: 1)
        create(:review, restaurant: restaurant, rating: 2)

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(1.33) # (1 + 1 + 2) / 3 = 1.33333... -> 1.33
      end

      it 'handles all minimum ratings' do
        5.times { create(:review, restaurant: restaurant, rating: 1) }

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(1.0)
      end

      it 'handles all maximum ratings' do
        5.times { create(:review, restaurant: restaurant, rating: 5) }

        result = CalculateRestaurantRating.call(restaurant)
        expect(result).to eq(5.0)
      end
    end

    context 'instance method usage' do
      it 'can be instantiated and called' do
        create(:review, restaurant: restaurant, rating: 4)

        service = CalculateRestaurantRating.new(restaurant)
        result = service.call

        expect(result).to eq(4.0)
      end

      it 'maintains state between calls when using instance' do
        service = CalculateRestaurantRating.new(restaurant)

        # First call with no reviews
        result1 = service.call
        expect(result1).to eq(0.0)

        # Add a review
        create(:review, restaurant: restaurant, rating: 3)

        # Second call should reflect the new review
        result2 = service.call
        expect(result2).to eq(3.0)
      end
    end


  end
end
