require 'rails_helper'

RSpec.describe CreateReview, type: :command do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, calculated_rating: 0.0) }
  let(:valid_params) do
    {
      user: user,
      restaurant: restaurant,
      rating: 4,
      comment: "Great food and excellent service!"
    }
  end

  describe '.call' do
    context 'with valid parameters' do
      it 'creates a new review' do
        expect {
          CreateReview.call(valid_params)
        }.to change { Review.count }.by(1)
      end

      it 'returns the created review' do
        result = CreateReview.call(valid_params)
        expect(result).to be_a(Review)
        expect(result.user).to eq(user)
        expect(result.restaurant).to eq(restaurant)
        expect(result.rating).to eq(4)
        expect(result.comment).to eq("Great food and excellent service!")
      end

      it 'updates the restaurant calculated_rating' do
        expect {
          CreateReview.call(valid_params)
        }.to change { restaurant.reload.calculated_rating }.from(0.0).to(4.0)
      end

      it 'persists the review to the database' do
        result = CreateReview.call(valid_params)
        persisted_review = Review.find(result.id)

        expect(persisted_review.user).to eq(user)
        expect(persisted_review.restaurant).to eq(restaurant)
        expect(persisted_review.rating).to eq(4)
        expect(persisted_review.comment).to eq("Great food and excellent service!")
      end
    end

    context 'with multiple reviews' do
      let(:user2) { create(:user, email_address: "user2@example.com") }
      let(:user3) { create(:user, email_address: "user3@example.com") }

      before do
        # Create first review
        CreateReview.call(valid_params.merge(rating: 5))
      end

      it 'calculates average rating correctly with second review' do
        CreateReview.call(valid_params.merge(user: user2, rating: 3))

        expect(restaurant.reload.calculated_rating).to eq(4.0) # (5 + 3) / 2 = 4.0
      end

      it 'calculates average rating correctly with three reviews' do
        CreateReview.call(valid_params.merge(user: user2, rating: 3))
        CreateReview.call(valid_params.merge(user: user3, rating: 2))

        expect(restaurant.reload.calculated_rating).to eq(3.33) # (5 + 3 + 2) / 3 = 3.33
      end

      it 'rounds rating to 2 decimal places' do
        CreateReview.call(valid_params.merge(user: user2, rating: 4))
        CreateReview.call(valid_params.merge(user: user3, rating: 4))

        # (5 + 4 + 4) / 3 = 4.33333... -> 4.33
        expect(restaurant.reload.calculated_rating).to eq(4.33)
      end
    end

    context 'transaction behavior' do
      it 'rolls back review creation if restaurant update fails' do
        # Stub the rating calculation to raise an error
        allow(CalculateRestaurantRating).to receive(:call).and_raise(StandardError, "Calculation failed")

        expect {
          begin
            CreateReviewCommand.call(valid_params)
          rescue StandardError
            # Swallow the error for this test
          end
        }.not_to change { Review.count }
      end

      it 'rolls back restaurant update if review creation fails' do
        invalid_params = valid_params.merge(comment: nil) # Invalid comment

        expect {
          begin
            CreateReview.call(invalid_params)
          rescue ActiveRecord::RecordInvalid
            # Swallow the error for this test
          end
        }.not_to change { restaurant.reload.calculated_rating }
      end

      it 'raises error when review creation fails' do
        invalid_params = valid_params.merge(rating: nil)

        expect {
          CreateReview.call(invalid_params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'validation errors' do
      it 'raises error with invalid rating' do
        invalid_params = valid_params.merge(rating: 6)

        expect {
          CreateReview.call(invalid_params)
        }.to raise_error(ActiveRecord::RecordInvalid, /Rating must be less than or equal to 5/)
      end

      it 'raises error with missing comment' do
        invalid_params = valid_params.merge(comment: nil)

        expect {
          CreateReview.call(invalid_params)
        }.to raise_error(ActiveRecord::RecordInvalid, /Comment can't be blank/)
      end

      it 'raises error with duplicate user-restaurant combination' do
        CreateReview.call(valid_params)

        expect {
          CreateReview.call(valid_params)
        }.to raise_error(ActiveRecord::RecordInvalid, /User can only review a restaurant once/)
      end

      it 'raises error with missing user' do
        invalid_params = valid_params.merge(user: nil)

        expect {
          CreateReview.call(invalid_params)
        }.to raise_error(ActiveRecord::RecordInvalid, /User must exist/)
      end

      it 'raises error with missing restaurant' do
        invalid_params = valid_params.merge(restaurant: nil)

        expect {
          CreateReview.call(invalid_params)
        }.to raise_error(ActiveRecord::RecordInvalid, /Restaurant must exist/)
      end
    end

    context 'edge cases' do
      it 'handles restaurant with no previous reviews' do
        expect(restaurant.calculated_rating).to eq(0.0)

        result = CreateReview.call(valid_params)

        expect(result).to be_persisted
        expect(restaurant.reload.calculated_rating).to eq(4.0)
      end

      it 'handles restaurant with existing calculated_rating' do
        restaurant.update!(calculated_rating: 3.5)

        result = CreateReview.call(valid_params)

        expect(result).to be_persisted
        expect(restaurant.reload.calculated_rating).to eq(4.0) # Recalculated from actual reviews
      end

      it 'handles minimum rating (1 star)' do
        result = CreateReview.call(valid_params.merge(rating: 1))

        expect(result.rating).to eq(1)
        expect(restaurant.reload.calculated_rating).to eq(1.0)
      end

      it 'handles maximum rating (5 stars)' do
        result = CreateReview.call(valid_params.merge(rating: 5))

        expect(result.rating).to eq(5)
        expect(restaurant.reload.calculated_rating).to eq(5.0)
      end

      it 'handles minimum length comment' do
        result = CreateReview.call(valid_params.merge(comment: "Good food!"))

        expect(result.comment).to eq("Good food!")
      end

      it 'handles maximum length comment' do
        long_comment = "a" * 1000
        result = CreateReview.call(valid_params.merge(comment: long_comment))

        expect(result.comment).to eq(long_comment)
      end
    end

    context 'instance method usage' do
      it 'can be instantiated and called' do
        command = CreateReview.new(valid_params)
        result = command.call

        expect(result).to be_a(Review)
        expect(result).to be_persisted
        expect(restaurant.reload.calculated_rating).to eq(4.0)
      end
    end
  end

  describe 'integration with CalculateRestaurantRating' do
    let(:user2) { create(:user, email_address: "user2@example.com") }
    let(:user3) { create(:user, email_address: "user3@example.com") }

    it 'calls CalculateRestaurantRating for rating calculation' do
      expect(CalculateRestaurantRating).to receive(:call).with(restaurant).and_return(4.0)

      CreateReview.call(valid_params)

      expect(restaurant.reload.calculated_rating).to eq(4.0)
    end

    it 'updates restaurant with the calculated rating' do
      # Mock the service to return a specific value
      allow(CalculateRestaurantRating).to receive(:call).and_return(3.75)

      CreateReview.call(valid_params)

      expect(restaurant.reload.calculated_rating).to eq(3.75)
    end

    it 'uses real calculation class by default' do
      CreateReview.call(valid_params.merge(rating: 5))
      CreateReview.call(valid_params.merge(user: user2, rating: 3))
      CreateReview.call(valid_params.merge(user: user3, rating: 4))

      # Real calculation: (5 + 3 + 4) / 3 = 4.0
      expect(restaurant.reload.calculated_rating).to eq(4.0)
    end
  end

  describe 'performance considerations' do
    # This test documents the N+1 query concern mentioned in the requirements
    it 'documents that rating calculation may not be performant with many reviews' do
      # Note: This is intentionally a documentation test rather than a performance test
      # In a real application, this might be optimized with:
      # 1. Background job processing
      # 2. Database-level calculations
      # 3. Cached aggregations
      # 4. Denormalized data structures

      expect(true).to eq(true) # Placeholder for documentation
    end
  end
end
