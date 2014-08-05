require "spec_helper"

describe Octopus::ScopeProxy do
  it "should allow nested queries" do
    @user1 = User.using(:brazil).create!(:name => "Thiago P", :number => 3)
    @user2 = User.using(:brazil).create!(:name => "Thiago", :number => 1)
    @user3 = User.using(:brazil).create!(:name => "Thiago", :number => 2)

    User.using(:brazil).where(:name => "Thiago").where(:number => 4).order(:number).all.should == []
    User.using(:brazil).where(:name => "Thiago").using(:canada).where(:number => 2).using(:brazil).order(:number).all.should == [@user3]
    User.using(:brazil).where(:name => "Thiago").using(:canada).where(:number => 4).using(:brazil).order(:number).all.should == []
  end

  context "When array-like-selecting an item in a group" do
    before(:each) do
      User.using(:brazil).create!(:name => "Evan", :number => 1)
      User.using(:brazil).create!(:name => "Evan", :number => 2)
      User.using(:brazil).create!(:name => "Evan", :number => 3)
      @evans = User.using(:brazil).where(:name => "Evan")
    end

    it "allows a block to select an item" do
      @evans.select{|u| u.number == 2}.first.number.should eq(2)
    end
  end

  context "When selecting a field within a scope" do
    before(:each) do
      User.using(:brazil).create!(:name => "Evan", :number => 4)
      @evan = User.using(:brazil).where(:name => "Evan")
    end

    it "allows single field selection" do
      @evan.select("name").first.name.should eq("Evan")
    end

    it "allows selection by array" do
      @evan.select(["name"]).first.name.should eq("Evan")
    end

    it "allows multiple selection by string" do
      @evan.select("id, name").first.id.should be_a Fixnum
    end

    it "allows multiple selection by array" do
      @evan.select(["id", "name"]).first.id.should be_a Fixnum
    end

    if Octopus.rails4?
      it "allows multiple selection by symbol" do
        @evan.select(:id, :name).first.id.should be_a Fixnum
      end

      it "allows multiple selection by string and symbol" do
        @evan.select(:id, "name").first.id.should be_a Fixnum
      end
    end
  end

  it "should raise a exception when trying to send a query to a shard that don't exists" do
    lambda { User.using(:dont_exists).all }.should raise_exception("Nonexistent Shard Name: dont_exists")
  end
end
