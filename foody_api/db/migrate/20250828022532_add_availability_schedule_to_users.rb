class AddAvailabilityScheduleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :availability_schedule, :json
  end
end
