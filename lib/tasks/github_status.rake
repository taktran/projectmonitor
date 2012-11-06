namespace :github_status do
  desc "Check Github to see if it is alive"
  task :check => :environment do
    uri = URI('https://status.github.com/status.json')
    response = {}

    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
       request = Net::HTTP::Get.new uri.request_uri
       response = http.request request
      end

      status = JSON.parse(response.body)[:status]
    rescue Net::HTTP::HTTPServerError => e
    end
  end
end
