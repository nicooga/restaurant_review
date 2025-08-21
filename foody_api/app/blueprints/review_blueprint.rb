class ReviewBlueprint < Blueprinter::Base
  identifier :id

  fields :rating, :comment, :created_at, :updated_at

  view :detail do
    association :user, blueprint: UserBlueprint
    association :restaurant, blueprint: RestaurantBlueprint
  end
end
