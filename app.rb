require 'sinatra'
require 'net/http'
require 'net/https'
require 'json'
require 'github'

set :ghuser, ENV['GH_USER']
set :ghpass, ENV['GH_PASSWORD']
set :token,  ENV['TOKEN']
set :ref, ENV['REF'] || "refs/heads/master"

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
    return "Ignoring commits to #{payload["ref"]}" unless payload["ref"] == settings.ref
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
    GitHub.nonclosing_issues(commit["message"]) do |issue|
      github.label_issue issue, params[:label]
    end
  end
end

post '/label/closed/:label/:token' do
  respond_to_commits do |commit|
    GitHub.closed_issues(commit["message"]) do |issue|
      github.label_issue issue, params[:label]
    end
  end
end

post '/label/remove/closed/:label/:token' do
  respond_to_commits do |commit|
    GitHub.closed_issues(commit["message"]) do |issue|
      github.remove_issue_label issue, params[:label]
    end
  end
end

post '/reopen/:token' do
  respond_to_commits do |commit|
    GitHub.closed_issues(commit["message"]) do |issue|
      github.reopen_issue issue
    end
  end
end

post '/comment/:token' do
  respond_to_commits do |commit|
    comment = <<EOM
Referenced by #{commit["id"]}

#{commit["message"]}

_Added by ghpong_
EOM
    GitHub.nonclosing_issues(commit["message"]) do |issue|
      github.comment_issue issue, comment
    end
  end
end

