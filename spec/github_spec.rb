require './github.rb'

describe GitHub do
  describe "issue" do
    it "should return nil when no issue detected" do
      GitHub.issue("fixes some stuff").should be_nil
      GitHub.issue("fixes gh-more").should be_nil
      GitHub.issue("fixes #34").should be_nil
    end

    it "should return issue number prefixed by gh-" do
      GitHub.issue("fixes gh-34").should == "34"
    end

    it "should return issue number prefixed by GH-" do
      GitHub.issue("fixes GH-34").should == "34"
    end
  end

  describe "closed_issue" do
    it "should return issue number of closed issue" do
      GitHub.closed_issues("fixes gh-34").should == ["34"]
      GitHub.closed_issues("fixes GH-34").should == ["34"]
      GitHub.closed_issues("fixes #34").should == ["34"]
    end

    it "should return nil when issue not closed" do
      GitHub.closed_issues("references GH-34").should == []
    end

    it "should yield each issue to a given block" do
      found_issues = []
      GitHub.closed_issues "fixes gh-34 and closes gh-35" do |issue|
        found_issues.push issue
      end
      found_issues.should == ["34", "35"]
    end
  end

  describe "nonclosing_issue" do
    it "should return issue number of issue prefixed by gh-" do
      GitHub.nonclosing_issues("changes gh-34").should == ["34"]
      GitHub.nonclosing_issues("changes GH-34").should == ["34"]
    end

    it "should return nil when issue doesnt have prefix" do
      GitHub.nonclosing_issues("changes #34").should == []
    end

    it "should return nil when no issue referenced" do
      GitHub.nonclosing_issues("changes nothing").should == []
    end

    it "should return nil when issue referenced is being closed" do
      GitHub.nonclosing_issues("fixes gh-34").should == [] 
      GitHub.nonclosing_issues("fixes GH-34").should == [] 
      GitHub.nonclosing_issues("fixes #34").should  == []
      GitHub.nonclosing_issues("closes #34").should == []
      GitHub.nonclosing_issues("Closes gh-34").should == [] 
    end

    it "should yield each issue to a given block" do
      found_issues = []
      GitHub.nonclosing_issues "changes gh-22 and fixes gh-34 and updates GH-35" do |issue|
        found_issues.push issue
      end
      found_issues.should == ["22", "35"]
    end
  end
end
