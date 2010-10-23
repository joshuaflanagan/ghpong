require './github.rb'

describe GitHub do
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
