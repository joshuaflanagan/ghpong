require './commitparser.rb'

describe CommitParser do
  it "should return nil when no issue detected" do
    CommitParser.issue("fixes some stuff").should be_nil
    CommitParser.issue("fixes gh-more").should be_nil
    CommitParser.issue("fixes #34").should be_nil
  end

  it "should return issue number prefixed by gh-" do
    CommitParser.issue("fixes gh-34").should == "34"
  end

  it "should return issue number prefixed by GH-" do
    CommitParser.issue("fixes GH-34").should == "34"
  end
end
