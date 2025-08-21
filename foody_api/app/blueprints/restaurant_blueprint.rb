class RestaurantBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :cuisine_type, :price_range,
         :address, :description, :phone, :image_url,
         :created_at, :updated_at

  field :calculated_rating do |restaurant|
    restaurant.calculated_rating.to_f
  end
end
