FactoryBot.define do
  factory :review do
    rating { 4 }
    comment { "Great food and excellent service. Would definitely recommend this place to others!" }
    association :user
    association :restaurant

    # Rating-specific traits
    trait :one_star do
      rating { 1 }
      comment { "Very disappointing experience. The food was terrible and service was poor." }
    end

    trait :two_stars do
      rating { 2 }
      comment { "Below average experience. Food was okay but service could be much better." }
    end

    trait :three_stars do
      rating { 3 }
      comment { "Average restaurant. Nothing special but not terrible either. Decent food and service." }
    end

    trait :four_stars do
      rating { 4 }
      comment { "Really good restaurant with tasty food and friendly staff. Will come back again." }
    end

    trait :five_stars do
      rating { 5 }
      comment { "Absolutely amazing! Best restaurant in town. Perfect food, atmosphere, and service." }
    end

    # Comment length traits
    trait :short_comment do
      comment { "Good food here." }
    end

    trait :long_comment do
      comment { "This restaurant exceeded all my expectations. From the moment we walked in, the atmosphere was perfect - cozy but elegant, with great lighting and music at just the right volume. Our server was incredibly knowledgeable about the menu and wine pairings, making excellent recommendations that perfectly complemented our meal. Every dish was prepared to perfection, with fresh ingredients and creative presentations. The flavors were outstanding and well-balanced. The timing between courses was ideal, giving us time to savor each dish without feeling rushed. Even the dessert was exceptional. I can't wait to come back and try more items from their menu. This is definitely going to be one of our regular spots!" }
    end

    # Specific restaurant traits
    trait :for_italian_restaurant do
      comment { "Authentic Italian cuisine with perfect pasta and great wine selection. Highly recommended!" }
    end

    trait :for_mexican_restaurant do
      comment { "Amazing Mexican food with fresh ingredients and bold flavors. The salsa was incredible!" }
    end

    trait :for_sushi_restaurant do
      comment { "Fresh sushi and great presentation. The chef clearly knows what they're doing." }
    end

    # User-specific traits
    trait :positive_reviewer do
      rating { 5 }
      comment { "Outstanding restaurant! Everything was perfect from start to finish. Can't wait to return!" }
    end

    trait :critical_reviewer do
      rating { 2 }
      comment { "Expected much better based on the reviews. Food was mediocre and service was slow." }
    end

    # Time-based traits
    trait :recent do
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
    end

    trait :old do
      created_at { 6.months.ago }
      updated_at { 6.months.ago }
    end

    # Combined traits
    trait :excellent_recent_review do
      five_stars
      recent
    end

    trait :poor_old_review do
      one_star
      old
    end

    # Minimal valid review for testing validations
    trait :minimal do
      rating { 3 }
      comment { "It was okay." }
    end
  end
end
