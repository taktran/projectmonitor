namespace :faye do
  desc "Start Faye Server"
  task :start => :environment do
    exec "rackup faye.ru -s thin -E production"
  end
end
