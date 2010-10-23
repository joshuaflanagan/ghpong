require 'sinatra'
require 'net/http'

set :ghuser, ENV['GH_USER']
set :ghpass, ENV['GH_PASSWORD']

get '/' do
  "GitHub Pong"
end

get '/ping/:label' do
  server = "github.com"
  api_path = "/api/v2/yaml"
  repo = "joshuaflanagan/gitk-demo"
  issue = 4
  add_label = "/issues/label/add/#{repo}/#{params[:label]}/#{issue}"
  request_path = api_path + add_label
  response = nil
  Net::HTTP.start(server) {|http|
      req = Net::HTTP::Get.new(request_path)
      req.basic_auth settings.ghuser + "/token", settings.ghpass 
      response = http.request(req)
    }
  "Added Label #{ params[:label]} via #{ request_path } returned #{response.code}"
end
