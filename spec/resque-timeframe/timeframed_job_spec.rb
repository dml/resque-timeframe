require File.join(File.dirname(__FILE__) + '/../spec_helper')

describe Resque::Plugins::Timeframe do

  context "Convention" do
    it "should follow the convention" do
      lambda {
        Resque::Plugin.lint(Resque::Plugins::Timeframe)
      }.should_not raise_error
    end

    it "should recognize time from range of strings" do
      @range = "01:00".."08:30"
      @date_range = Time.parse("01:00")..Time.parse("08:30")
      RegularWeekRestrictionJob.range(@range).should be_kind_of(Range)
      RegularWeekRestrictionJob.range(@range).should == @date_range
    end

    it "should recognize time from range of integers" do
      @range = 4..16
      @date_range = Time.parse("04:00")..Time.parse("16:00")
      RegularWeekRestrictionJob.range(@range).should be_kind_of(Range)
      RegularWeekRestrictionJob.range(@range).should == @date_range
    end

    it "should recognize time from range of time instances" do
      @date_range = Time.parse("04:00")..Time.parse("16:00")
      RegularWeekRestrictionJob.range(@date_range).should be_kind_of(Range)
      RegularWeekRestrictionJob.range(@date_range).should == @date_range
    end
  end

  context "Settings" do
    it "should allowed by default" do
      AllowedByDefaultTimeframeJob.allowed_at?(:monday).should be_true
    end

    it "should be restrict if default set to false" do
      RestrictedByDefaultTimeframeJob.allowed_at?(:monday).should be_false
    end

    it "should allow a job if exact time range specified" do
      Time.stub!(:now).and_return(Time.parse("11:21"))
      RegularWeekRestrictionJob.allowed_at?(:thursday).should be_true
    end

    it "should does not allow a job if exact time range specified but out of current time" do
      Time.stub!(:now).and_return(Time.parse("11:21"))
      RegularWeekRestrictionJob.allowed_at?(:friday).should be_false
    end
  end

  context "Resque" do
    before(:all) do
      Resque.redis.flushall
    end

    it "does something" do
      true.should == true
    end
  end

end
