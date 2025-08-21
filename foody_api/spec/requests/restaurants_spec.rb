require 'rails_helper'

RSpec.describe "Restaurants", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email_address: "other@example.com") }

  describe "GET /restaurants" do
    let!(:italian_restaurant) { create(:restaurant, :italian, :moderate, name: "Mario's", calculated_rating: 4.5) }
    let!(:mexican_restaurant) { create(:restaurant, :mexican, :budget, name: "Tacos", calculated_rating: 3.8) }
    let!(:thai_restaurant) { create(:restaurant, :thai, :upscale, name: "Thai Palace", calculated_rating: 4.2) }

    context "without filters or sorting" do
      it "returns all restaurants with default sorting" do
        get "/restaurants"

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body)
        expect(json.length).to eq(3)

        # Default sort: rating desc, then name asc
        expect(json[0]["name"]).to eq("Mario's")
        expect(json[1]["name"]).to eq("Thai Palace")
        expect(json[2]["name"]).to eq("Tacos")
      end

      it "includes all restaurant attributes" do
        get "/restaurants"

        json = JSON.parse(response.body)
        restaurant = json.first

        expect(restaurant).to include(
          "id",
          "name",
          "cuisine_type",
          "price_range",
          "calculated_rating",
          "address",
          "description",
          "phone",
          "image_url",
          "created_at",
          "updated_at"
        )
      end
    end

    context "with filters" do
      it "filters by name" do
        get "/restaurants", params: {
          filters: { name: "mario" }
        }

        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json[0]["name"]).to eq("Mario's")
      end

      it "filters by cuisine_type" do
        get "/restaurants", params: {
          filters: { cuisine_type: "mexican" }
        }

        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json[0]["cuisine_type"]).to eq("mexican")
      end

      it "filters by max_price" do
        get "/restaurants", params: {
          filters: { max_price: 2 }  # moderate and below
        }

        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        restaurant_names = json.map { |r| r["name"] }
        expect(restaurant_names).to include("Mario's", "Tacos")
        expect(restaurant_names).not_to include("Thai Palace")
      end

      it "filters by min_rating" do
        get "/restaurants", params: {
          filters: { min_rating: 4.0 }
        }

        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        restaurant_names = json.map { |r| r["name"] }
        expect(restaurant_names).to include("Mario's", "Thai Palace")
        expect(restaurant_names).not_to include("Tacos")
      end

      it "combines multiple filters" do
        get "/restaurants", params: {
          filters: {
            cuisine_type: "italian",
            min_rating: 4.0,
            max_price: 2
          }
        }

        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json[0]["name"]).to eq("Mario's")
      end

      it "returns empty array when no matches" do
        get "/restaurants", params: {
          filters: { name: "nonexistent" }
        }

        json = JSON.parse(response.body)
        expect(json).to eq([])
      end
    end

    context "with sorting" do
      it "sorts by name ascending" do
        get "/restaurants", params: {
          sort: { by: "name", direction: "asc" }
        }

        json = JSON.parse(response.body)
        expect(json.map { |r| r["name"] }).to eq(["Mario's", "Tacos", "Thai Palace"])
      end

      it "sorts by name descending" do
        get "/restaurants", params: {
          sort: { by: "name", direction: "desc" }
        }

        json = JSON.parse(response.body)
        expect(json.map { |r| r["name"] }).to eq(["Thai Palace", "Tacos", "Mario's"])
      end

      it "sorts by rating ascending" do
        get "/restaurants", params: {
          sort: { by: "rating", direction: "asc" }
        }

        json = JSON.parse(response.body)
        expect(json.map { |r| r["calculated_rating"].to_f }).to eq([3.8, 4.2, 4.5])
      end

      it "sorts by rating descending" do
        get "/restaurants", params: {
          sort: { by: "rating", direction: "desc" }
        }

        json = JSON.parse(response.body)
        expect(json.map { |r| r["calculated_rating"].to_f }).to eq([4.5, 4.2, 3.8])
      end
    end

    context "with filters and sorting combined" do
      it "applies filters then sorting" do
        get "/restaurants", params: {
          filters: { min_rating: 4.0 },
          sort: { by: "name", direction: "asc" }
        }

        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json.map { |r| r["name"] }).to eq(["Mario's", "Thai Palace"])
      end
    end
  end

  describe "GET /restaurants/:id" do
    let(:restaurant) { create(:restaurant, :italian, name: "Test Restaurant") }

    context "when restaurant exists" do
      it "returns the restaurant" do
        get "/restaurants/#{restaurant.id}"

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body)
        expect(json["id"]).to eq(restaurant.id)
        expect(json["name"]).to eq("Test Restaurant")
        expect(json["cuisine_type"]).to eq("italian")
      end

      it "includes all restaurant attributes" do
        get "/restaurants/#{restaurant.id}"

        json = JSON.parse(response.body)
        expect(json).to include(
          "id",
          "name",
          "cuisine_type",
          "price_range",
          "calculated_rating",
          "address",
          "description",
          "phone",
          "image_url",
          "created_at",
          "updated_at"
        )
      end
    end

    context "when restaurant does not exist" do
      it "returns not found error" do
        get "/restaurants/99999"

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Restaurant not found")
      end
    end
  end

  describe "GET /restaurants/:id/reviews" do
    let(:restaurant) { create(:restaurant) }
    let!(:old_review) { create(:review, restaurant: restaurant, user: user, rating: 4, created_at: 2.days.ago) }
    let!(:new_review) { create(:review, restaurant: restaurant, user: other_user, rating: 5, created_at: 1.day.ago) }

    context "when restaurant exists" do
      it "returns reviews ordered by most recent first" do
        get "/restaurants/#{restaurant.id}/reviews"

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body)
        expect(json.length).to eq(2)

        # Most recent first
        expect(json[0]["id"]).to eq(new_review.id)
        expect(json[0]["rating"]).to eq(5)
        expect(json[1]["id"]).to eq(old_review.id)
        expect(json[1]["rating"]).to eq(4)
      end

      it "includes review attributes and user information" do
        get "/restaurants/#{restaurant.id}/reviews"

        json = JSON.parse(response.body)
        review = json.first

        expect(review).to include(
          "id",
          "rating",
          "comment",
          "created_at",
          "updated_at",
          "user"
        )

        expect(review["user"]).to include(
          "id",
          "email_address"
        )
      end

      it "returns empty array when restaurant has no reviews" do
        empty_restaurant = create(:restaurant)
        get "/restaurants/#{empty_restaurant.id}/reviews"

        json = JSON.parse(response.body)
        expect(json).to eq([])
      end
    end

    context "when restaurant does not exist" do
      it "returns not found error" do
        get "/restaurants/99999/reviews"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Restaurant not found")
      end
    end
  end

  describe "POST /restaurants/:id/reviews" do
    let(:restaurant) { create(:restaurant, calculated_rating: 0.0) }
    let(:valid_params) do
      {
        rating: 4,
        comment: "Great food and excellent service!"
      }
    end

    context "when user is authenticated" do
      before do
        sign_in_as(user)
      end

      context "with valid parameters" do
        it "creates a new review" do
          expect {
            post "/restaurants/#{restaurant.id}/reviews", params: valid_params
          }.to change { Review.count }.by(1)
        end

        it "returns the created review" do
          post "/restaurants/#{restaurant.id}/reviews", params: valid_params

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq("application/json; charset=utf-8")

          json = JSON.parse(response.body)
          expect(json["rating"]).to eq(4)
          expect(json["comment"]).to eq("Great food and excellent service!")
          expect(json["user"]["id"]).to eq(user.id)
          expect(json["restaurant"]["id"]).to eq(restaurant.id)
        end

        it "updates the restaurant's calculated rating" do
          expect {
            post "/restaurants/#{restaurant.id}/reviews", params: valid_params
          }.to change { restaurant.reload.calculated_rating }.from(0.0).to(4.0)
        end

        it "includes all review attributes in response" do
          post "/restaurants/#{restaurant.id}/reviews", params: valid_params

          json = JSON.parse(response.body)
          expect(json).to include(
            "id",
            "rating",
            "comment",
            "user",
            "restaurant",
            "created_at",
            "updated_at"
          )
        end
      end

      context "with invalid parameters" do
        it "returns validation errors for missing rating" do
          post "/restaurants/#{restaurant.id}/reviews", params: { comment: "Great food!" }

          expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq("Review could not be created")
          expect(json["errors"]).to include("Rating can't be blank")
        end

        it "returns validation errors for invalid rating" do
          post "/restaurants/#{restaurant.id}/reviews", params: {
            rating: 6,
            comment: "Great food!"
          }

          expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json["errors"]).to include("Rating must be less than or equal to 5")
        end

        it "returns validation errors for missing comment" do
          post "/restaurants/#{restaurant.id}/reviews", params: { rating: 4 }

          expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json["errors"]).to include("Comment can't be blank")
        end

        it "returns validation errors for short comment" do
          post "/restaurants/#{restaurant.id}/reviews", params: {
            rating: 4,
            comment: "Bad"
          }

          expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json["errors"]).to include("Comment is too short (minimum is 10 characters)")
        end

        it "returns validation error for duplicate review" do
          create(:review, user: user, restaurant: restaurant)

          post "/restaurants/#{restaurant.id}/reviews", params: valid_params

          expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json["errors"]).to include("User can only review a restaurant once")
        end
      end

      context "when restaurant does not exist" do
        it "returns not found error" do
          post "/restaurants/99999/reviews", params: valid_params

          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq("Restaurant not found")
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized error" do
        post "/restaurants/#{restaurant.id}/reviews", params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
