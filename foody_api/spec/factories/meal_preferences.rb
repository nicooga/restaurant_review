FactoryBot.define do
  factory :meal_preference do
    user { nil }
    cusine_preferences { "" }
    preferred_location_lat { "9.99" }
    preferred_location_lng { "9.99" }
    availability_schedule { "" }
  end
end
