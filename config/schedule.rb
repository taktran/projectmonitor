every :day, :at => '11:35am' do
  rake "truncate_ci_server_logs"
end
