class MealPlan < ApplicationRecord
    has_many :memberships, class_name: 'MealPlanMember'
    has_many :members, through: :memberships, source: :user
end
