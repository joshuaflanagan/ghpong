require 'sinatra'
require 'net/http'
require 'net/https'
require 'json'
require 'github'

set :ghuser, ENV['GH_USER']
set :ghpass, ENV['GH_PASSWORD']

helpers do
  def payload
    @payload ||= JSON.parse(params[:payload])
  end

  def repo
    @repo ||= "#{payload["repository"]["owner"]["name"]}/#{payload["repository"]["name"]}"
  end

  def github
    @github ||= GitHub.new("joshuaflanagan/gitk-demo", settings.ghuser + "/token", settings.ghpass)
  end
end

get '/' do
  "GitHub Pong"
end

post '/ping/label/:label' do
  output = "REPO: #{repo} - #{request.ip}\n"
  payload["commits"].each do |commit|
    issue = GitHub.issue(commit["message"])
    
    output << "issue #{issue}\n" unless issue.nil?
  end
  output
end

get '/test/:label' do
  response = github.label_issue 4, params[:label]
  "Added Label #{ params[:label]} returned #{response.code} #{response.body}"
end
