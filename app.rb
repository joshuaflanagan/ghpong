require 'sinatra'
require 'net/http'
require 'json'
require 'commitparser'

set :ghuser, ENV['GH_USER']
set :ghpass, ENV['GH_PASSWORD']

helpers do
  def payload
    @payload ||= JSON.parse(params[:payload])
  end

  def repo
    @repo ||= "#{payload["repository"]["owner"]["name"]}/#{payload["repository"]["name"]}"
  end
end

get '/' do
  "GitHub Pong"
end

post '/ping/label/:label' do
  output = "REPO: #{repo} - #{request.ip}\n"
  payload["commits"].each do |commit|
    issue = CommitParser.issue(commit["message"])
    
    output << "issue #{issue}\n" unless issue.nil?
  end
  output
end

get '/test/:label' do
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
