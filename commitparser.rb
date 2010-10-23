module CommitParser
  def self.issue(message)
    message[/gh-(\d+)/i,1]
  end
end
