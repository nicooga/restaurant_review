require 'rails_helper'

RSpec.describe RestaurantIndexQuery, type: :query do
  # Integration example showing typical usage patterns
  describe 'integration examples' do
    let!(:pizza_place) { create(:restaurant, :italian, :budget, name: "Tony's Pizza", calculated_rating: 4.0) }
    let!(:fine_dining) { create(:restaurant, :french, :upscale, name: "Le Bistro", calculated_rating: 4.8) }
    let!(:taco_truck) { create(:restaurant, :mexican, :budget, name: "El Taco", calculated_rating: 3.5) }

    it 'demonstrates common search patterns' do
      # Search for budget Italian restaurants, sorted by rating
      result = RestaurantIndexQuery.call(
        filters: { cuisine_type: :italian, max_price: 1 },
        sort: { by: 'rating', direction: 'desc' }
      )
      expect(result).to eq([pizza_place])

      # Search for restaurants with "taco" in name
      result = RestaurantIndexQuery.call(
        filters: { name: 'taco' }
      )
      expect(result).to eq([taco_truck])

      # Get all restaurants sorted by name
      result = RestaurantIndexQuery.call(
        sort: { by: 'name', direction: 'asc' }
      )
      expect(result.map(&:name)).to eq(["El Taco", "Le Bistro", "Tony's Pizza"])
    end
  end
  describe '.call' do
    let!(:italian_budget) { create(:restaurant, :italian, :budget, name: "Tony's Pizza", calculated_rating: 4.0) }
    let!(:italian_upscale) { create(:restaurant, :italian, :upscale, name: "Bella Vista", calculated_rating: 4.8) }
    let!(:mexican_moderate) { create(:restaurant, :mexican, :moderate, name: "Casa Mexico", calculated_rating: 3.5) }
    let!(:thai_budget) { create(:restaurant, :thai, :budget, name: "Thai Garden", calculated_rating: 4.5) }
    let!(:american_upscale) { create(:restaurant, :american, :upscale, name: "Main Street Grill", calculated_rating: 4.2) }

    context 'without parameters' do
      it 'returns all restaurants with default sorting' do
        result = RestaurantIndexQuery.call
        expect(result).to match_array([italian_budget, italian_upscale, mexican_moderate, thai_budget, american_upscale])
      end

      it 'sorts by rating desc, then name asc by default' do
        result = RestaurantIndexQuery.call
        expect(result).to eq([italian_upscale, thai_budget, american_upscale, italian_budget, mexican_moderate])
      end
    end

    context 'with empty parameters' do
      it 'returns all restaurants' do
        result = RestaurantIndexQuery.call({})
        expect(result.count).to eq(5)
      end

      it 'handles nil params' do
        result = RestaurantIndexQuery.call(nil)
        expect(result.count).to eq(5)
      end
    end

    context 'filtering' do
      describe 'by name' do
        it 'filters restaurants by partial name match' do
          result = RestaurantIndexQuery.call(filters: { name: 'pizza' })
          expect(result).to include(italian_budget)
          expect(result).not_to include(italian_upscale, mexican_moderate, thai_budget, american_upscale)
        end

        it 'filters restaurants with case insensitive search' do
          result = RestaurantIndexQuery.call(filters: { name: 'BELLA' })
          expect(result).to include(italian_upscale)
          expect(result.count).to eq(1)
        end

        it 'returns empty array when no matches found' do
          result = RestaurantIndexQuery.call(filters: { name: 'nonexistent' })
          expect(result).to be_empty
        end

        it 'ignores empty name filter' do
          result = RestaurantIndexQuery.call(filters: { name: '' })
          expect(result.count).to eq(5)
        end
      end

      describe 'by cuisine_type' do
        it 'filters restaurants by cuisine type symbol' do
          result = RestaurantIndexQuery.call(filters: { cuisine_type: :italian })
          expect(result).to include(italian_budget, italian_upscale)
          expect(result).not_to include(mexican_moderate, thai_budget, american_upscale)
        end

        it 'filters restaurants by cuisine type string' do
          result = RestaurantIndexQuery.call(filters: { cuisine_type: 'mexican' })
          expect(result).to include(mexican_moderate)
          expect(result.count).to eq(1)
        end

        it 'ignores empty cuisine_type filter' do
          result = RestaurantIndexQuery.call(filters: { cuisine_type: '' })
          expect(result.count).to eq(5)
        end
      end

      describe 'by max_price' do
        it 'filters restaurants by max price (budget only)' do
          result = RestaurantIndexQuery.call(filters: { max_price: 1 })
          expect(result).to include(italian_budget, thai_budget)
          expect(result).not_to include(italian_upscale, mexican_moderate, american_upscale)
        end

        it 'filters restaurants by max price (moderate and below)' do
          result = RestaurantIndexQuery.call(filters: { max_price: 2 })
          expect(result).to include(italian_budget, mexican_moderate, thai_budget)
          expect(result).not_to include(italian_upscale, american_upscale)
        end

        it 'includes all restaurants when max price is upscale' do
          result = RestaurantIndexQuery.call(filters: { max_price: 3 })
          expect(result.count).to eq(5)
        end

        it 'ignores empty max_price filter' do
          result = RestaurantIndexQuery.call(filters: { max_price: '' })
          expect(result.count).to eq(5)
        end
      end

      describe 'by min_rating' do
        it 'filters restaurants by minimum rating' do
          result = RestaurantIndexQuery.call(filters: { min_rating: 4.0 })
          expect(result).to include(italian_budget, italian_upscale, thai_budget, american_upscale)
          expect(result).not_to include(mexican_moderate)
        end

        it 'filters restaurants by higher minimum rating' do
          result = RestaurantIndexQuery.call(filters: { min_rating: 4.5 })
          expect(result).to include(italian_upscale, thai_budget)
          expect(result).not_to include(italian_budget, mexican_moderate, american_upscale)
        end

        it 'returns empty array when min rating is too high' do
          result = RestaurantIndexQuery.call(filters: { min_rating: 5.0 })
          expect(result).to be_empty
        end

        it 'ignores empty min_rating filter' do
          result = RestaurantIndexQuery.call(filters: { min_rating: '' })
          expect(result.count).to eq(5)
        end
      end

      describe 'multiple filters' do
        it 'combines name and cuisine_type filters' do
          result = RestaurantIndexQuery.call(filters: { name: 'bella', cuisine_type: :italian })
          expect(result).to include(italian_upscale)
          expect(result.count).to eq(1)
        end

        it 'combines cuisine_type and max_price filters' do
          result = RestaurantIndexQuery.call(filters: { cuisine_type: :italian, max_price: 1 })
          expect(result).to include(italian_budget)
          expect(result).not_to include(italian_upscale)
        end

        it 'combines max_price and min_rating filters' do
          result = RestaurantIndexQuery.call(filters: { max_price: 2, min_rating: 4.0 })
          expect(result).to include(italian_budget, thai_budget)
          expect(result).not_to include(mexican_moderate, italian_upscale, american_upscale)
        end

        it 'combines all filters' do
          result = RestaurantIndexQuery.call(filters: {
            name: 'thai',
            cuisine_type: :thai,
            max_price: 1,
            min_rating: 4.0
          })
          expect(result).to include(thai_budget)
          expect(result.count).to eq(1)
        end

        it 'returns empty when filters have no matches' do
          result = RestaurantIndexQuery.call(filters: {
            cuisine_type: :thai,
            max_price: 1,
            min_rating: 5.0
          })
          expect(result).to be_empty
        end
      end
    end

    context 'sorting' do
      describe 'by name' do
        it 'sorts by name ascending' do
          result = RestaurantIndexQuery.call(sort: { by: 'name', direction: 'asc' })
          expect(result.map(&:name)).to eq([
            "Bella Vista", "Casa Mexico", "Main Street Grill", "Thai Garden", "Tony's Pizza"
          ])
        end

        it 'sorts by name descending' do
          result = RestaurantIndexQuery.call(sort: { by: 'name', direction: 'desc' })
          expect(result.map(&:name)).to eq([
            "Tony's Pizza", "Thai Garden", "Main Street Grill", "Casa Mexico", "Bella Vista"
          ])
        end

        it 'defaults to ascending when direction not specified' do
          result = RestaurantIndexQuery.call(sort: { by: 'name' })
          expect(result.first.name).to eq("Bella Vista")
          expect(result.last.name).to eq("Tony's Pizza")
        end
      end

      describe 'by rating' do
        it 'sorts by rating ascending' do
          result = RestaurantIndexQuery.call(sort: { by: 'rating', direction: 'asc' })
          expect(result.map(&:calculated_rating)).to eq([3.5, 4.0, 4.2, 4.5, 4.8])
        end

        it 'sorts by rating descending' do
          result = RestaurantIndexQuery.call(sort: { by: 'rating', direction: 'desc' })
          expect(result.map(&:calculated_rating)).to eq([4.8, 4.5, 4.2, 4.0, 3.5])
        end
      end

      describe 'by price_range' do
        it 'sorts by price_range ascending' do
          result = RestaurantIndexQuery.call(sort: { by: 'price_range', direction: 'asc' })
          budget_restaurants = result.select { |r| r.price_range == 'budget' }
          moderate_restaurants = result.select { |r| r.price_range == 'moderate' }
          upscale_restaurants = result.select { |r| r.price_range == 'upscale' }

          expect(budget_restaurants.count).to eq(2)
          expect(moderate_restaurants.count).to eq(1)
          expect(upscale_restaurants.count).to eq(2)
          expect(result.first.price_range).to eq('budget')
          expect(result.last.price_range).to eq('upscale')
        end

        it 'sorts by price_range descending' do
          result = RestaurantIndexQuery.call(sort: { by: 'price_range', direction: 'desc' })
          expect(result.first.price_range).to eq('upscale')
          expect(result.last.price_range).to eq('budget')
        end
      end

      describe 'by created_at' do
        it 'sorts by created_at ascending' do
          result = RestaurantIndexQuery.call(sort: { by: 'created_at', direction: 'asc' })
          expect(result.first).to eq(italian_budget) # created first
          expect(result.last).to eq(american_upscale) # created last
        end

        it 'sorts by created_at descending' do
          result = RestaurantIndexQuery.call(sort: { by: 'created_at', direction: 'desc' })
          expect(result.first).to eq(american_upscale) # created last
          expect(result.last).to eq(italian_budget) # created first
        end
      end

      describe 'default sorting' do
        it 'sorts by rating desc, then name asc when no sort specified' do
          result = RestaurantIndexQuery.call(sort: {})
          expect(result.map(&:name)).to eq([
            "Bella Vista", "Thai Garden", "Main Street Grill", "Tony's Pizza", "Casa Mexico"
          ])
        end

        it 'sorts by rating desc, then name asc with invalid sort by' do
          result = RestaurantIndexQuery.call(sort: { by: 'invalid' })
          expect(result.map(&:calculated_rating)).to eq([4.8, 4.5, 4.2, 4.0, 3.5])
        end
      end
    end

    context 'combining filters and sorting' do
      it 'applies filters then sorting' do
        result = RestaurantIndexQuery.call(
          filters: { cuisine_type: :italian },
          sort: { by: 'rating', direction: 'asc' }
        )
        expect(result).to eq([italian_budget, italian_upscale])
        expect(result.map(&:calculated_rating)).to eq([4.0, 4.8])
      end

      it 'applies multiple filters with custom sorting' do
        result = RestaurantIndexQuery.call(
          filters: { max_price: 2, min_rating: 4.0 },
          sort: { by: 'name', direction: 'desc' }
        )
        expect(result.map(&:name)).to eq(["Tony's Pizza", "Thai Garden"])
      end
    end

    context 'instance methods' do
      it 'can be instantiated and called' do
        query = RestaurantIndexQuery.new(filters: { cuisine_type: :italian })
        result = query.call
        expect(result).to include(italian_budget, italian_upscale)
        expect(result.count).to eq(2)
      end

      it 'handles nil params in initialize' do
        query = RestaurantIndexQuery.new(nil)
        result = query.call
        expect(result.count).to eq(5)
      end
    end
  end
end
