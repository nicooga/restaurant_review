class MealPlanMember < ApplicationRecord
  belongs_to :user
  belongs_to :meal_plan
end
