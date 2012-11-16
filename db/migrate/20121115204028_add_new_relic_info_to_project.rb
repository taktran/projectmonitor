class AddNewRelicInfoToProject < ActiveRecord::Migration
  def change
    add_column :projects, :new_relic_api_key, :string
    add_column :projects, :new_relic_app_id, :string
    add_column :projects, :new_relic_account_id, :string
    add_column :projects, :new_relic_online, :boolean
    add_column :projects, :new_relic_response_times, :text
  end
end
