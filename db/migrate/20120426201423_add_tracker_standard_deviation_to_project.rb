class AddTrackerStandardDeviationToProject < ActiveRecord::Migration
  def change
    add_column :projects, :tracker_standard_deviation, :double
  end
end
