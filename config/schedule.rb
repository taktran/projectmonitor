every :day, :at => '12:00pm' do
  rake "truncate_ci_server_logs"
end
