class CreateMealPlanMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_plan_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal_plan, null: false, foreign_key: true

      t.timestamps
    end
  end
end
