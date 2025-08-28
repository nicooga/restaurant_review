class CreateMealPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_plans do |t|
      t.json :proposed_restaurants
      t.json :proposed_time_slots
      t.json :poll

      t.timestamps
    end
  end
end
