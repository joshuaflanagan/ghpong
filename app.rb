require 'sinatra'
require 'net/http'
require 'net/https'
require 'json'
require 'github'

set :ghuser, ENV['GH_USER']
set :ghpass, ENV['GH_PASSWORD']
set :token,  ENV['TOKEN']

helpers do
  def payload
    @payload ||= JSON.parse(params[:payload])
  end

  def repo
    @repo ||= "#{payload["repository"]["owner"]["name"]}/#{payload["repository"]["name"]}"
  end

  def github
    @github ||= GitHub.new(repo, settings.ghuser + "/token", settings.ghpass)
  end

  def authorized?
    settings.token == params[:token]
  end
end

get '/' do
  "GitHub Pong"
end

post '/ping/label/:label/:token' do
  return "UNKNOWN APP" unless authorized?
  payload["commits"].each do |commit|
    issue = GitHub.issue(commit["message"])
    github.label_issue issue, params[:label] if issue
  end
  "OK"
end

post '/ping/reopen/:token' do
  return "UNKNOWN APP" unless authorized?
  payload["commits"].each do |commit|
    issue = GitHub.closed_issue(commit["message"])
    github.reopen_issue issue if issue
  end
  "OK"
end

get '/test/:label' do
  response = github.label_issue 4, params[:label]
  "Added Label #{ params[:label]} returned #{response.code} #{response.body}"
end
