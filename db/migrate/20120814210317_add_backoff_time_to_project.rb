class AddBackoffTimeToProject < ActiveRecord::Migration
  def change
    add_column :projects, :backoff_time, :integer, default: 0
  end
end
