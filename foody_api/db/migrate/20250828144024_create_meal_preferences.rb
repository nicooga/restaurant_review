class CreateMealPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.json :cusine_preferences
      t.decimal :preferred_location_lat
      t.decimal :preferred_location_lng
      t.json :availability_schedule

      t.timestamps
    end
  end
end
