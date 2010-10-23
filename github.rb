require 'rubygems'
require 'httparty'

class GitHub
  include HTTParty
  base_uri "https://github.com/api/v2/json"

  def initialize(repo, user="", pass="")
    @user = user
    @pass = pass
    @repo = repo
  end

  def label_issue(issue, label)
    options = @user.nil? ? {} : { :basic_auth => {:username => @user, :password => @pass}}
    self.class.post("/issues/label/add/#{@repo}/#{label}/#{issue}", options)
  end

  def reopen_issue(issue)
    options = @user.nil? ? {} : { :basic_auth => {:username => @user, :password => @pass}}
    self.class.post("/issues/reopen/#{@repo}/#{issue}", options)
  end

  def self.issue(message)
    message[/gh-(\d+)/i,1]
  end

  def self.closed_issue(message)
    message[/(closes|fixes) (gh-|#)(\d+)/i,3]
  end

  def self.nonclosing_issue(message)
    match = message.match /(closes|fixes)? (gh-|#)(\d+)/i
    if match && match[1].nil? && match[2] != "#"
      match[3]
    else
      nil
    end
  end
end
