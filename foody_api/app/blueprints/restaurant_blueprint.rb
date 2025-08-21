class RestaurantBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :cuisine_type, :price_range, :calculated_rating,
         :address, :description, :phone, :image_url,
         :created_at, :updated_at
end
