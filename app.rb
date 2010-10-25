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
    @github ||= GitHub.new(repo, settings.ghuser, settings.ghpass)
  end

  def authorized?
    settings.token == params[:token]
  end

  def respond_to_commits
    return "UNKNOWN APP" unless authorized?
    payload["commits"].reverse.each do |commit|
      yield commit
    end
    "OK"
  end
end

get '/' do
  "GitHub Pong"
end

post '/label/refer/:label/:token' do
  respond_to_commits do |commit|
    issue = GitHub.nonclosing_issue(commit["message"])
    github.label_issue issue, params[:label] if issue
  end
end

post '/label/closed/:label/:token' do
  respond_to_commits do |commit|
    issue = GitHub.closed_issue(commit["message"])
    github.label_issue issue, params[:label] if issue
  end
end

post '/reopen/:token' do
  respond_to_commits do |commit|
    issue = GitHub.closed_issue(commit["message"])
    github.reopen_issue issue if issue
  end
end

post '/comment/:token' do
  respond_to_commits do |commit|
    comment = <<EOM
Referenced by #{commit["id"]}

#{commit["message"]}

_Added by ghpong_
EOM
    issue = GitHub.nonclosing_issue(commit["message"])
    github.comment_issue issue, comment if issue
  end
end

