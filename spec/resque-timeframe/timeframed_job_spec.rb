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

  context "Timeframe" do
    before(:all) do
      @klass = Class.new
      @klass.extend Resque::Plugins::Timeframe
    end

    it "should have defined weeks" do
      @klass.week.should be_kind_of(Array)
    end

    it "should have defined settings" do
      @klass.settings.should be_kind_of(Hash)
    end

    it "should default true for a weeks days" do
      @klass.week.each do |dayoweek|
        @klass.settings[dayoweek].should be_true
      end
    end

    context "defining a day timeframe" do
      before(:each) do
        @day_of_week = :monday
        @period = 2..11
        @klass.timeframe @day_of_week => @period
      end

      it "should set one day settings" do
        @klass.settings[@day_of_week].should == @period
      end

      it "should not affect other day settings" do
        (@klass.week - [:monday]).each do |dayoweek|
          @klass.settings[dayoweek].should be_true
        end
      end
    end

    context "defining few days timeframes" do
      before(:each) do
        @days_of_week = [:monday, :wednesday, :friday]
        @period = 7..19
        @klass.timeframe @days_of_week => @period
      end

      it "should set one day settings" do
        @days_of_week.each do |dayoweek|
          @klass.settings[dayoweek].should == @period
        end
      end

      it "should not affect other day settings" do
        (@klass.week - @days_of_week).each do |dayoweek|
          @klass.settings[dayoweek].should be_true
        end
      end
    end

    context "defining few days timeframes" do
      before(:each) do
        @days_of_week1 = [:monday, :wednesday]
        @day_of_week2 = :friday
        @period1 = 7..19
        @period2 = 3..16
        @klass.timeframe @days_of_week1 => @period1, @day_of_week2 => @period2
      end

      it "should set one day settings" do
        @days_of_week1.each do |dayoweek|
          @klass.settings[dayoweek].should == @period1
        end
        @klass.settings[@day_of_week2].should == @period2
      end

      it "should not affect other day settings" do
        (@klass.week - @days_of_week1 - [@day_of_week2]).each do |dayoweek|
          @klass.settings[dayoweek].should be_true
        end
      end
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
      @time = Time.mktime(2010, 8, 11, 11, 21, 00)
      Time.stub!(:now).and_return(@time)
      RegularWeekRestrictionJob.allowed_at?(:thursday).should be_true
    end

    it "should does not allow a job if exact time range specified but out of current time" do
      @time = Time.mktime(2010, 8, 11, 12, 33, 00)
      Time.stub!(:now).and_return(@time)
      RegularWeekRestrictionJob.allowed_at?(:friday).should be_false
    end
  end

  context "Resque" do
    include PerformJob

    before(:each) do
      Resque.redis.flushall
      @time = Time.mktime(2010, 8, 11, 11, 59, 00)
      Time.stub!(:now).and_return(@time)
    end

    it "should perform job if timeframe is allowed" do
      AllowedByDefaultTimeframeJob.should_receive(:perform).and_return("OK")
      result = perform_job(AllowedByDefaultTimeframeJob, 1)
      result.should be_true
    end

    it "should not perform job if timeframe is restricted" do
      RestrictedByDefaultTimeframeJob.should_not_receive(:perform)
      result = perform_job(RestrictedByDefaultTimeframeJob, 1)
      result.should be_false
    end

    it "should delay job on a minute if job is out of timeframe" do
      RestrictedByDefaultTimeframeJob.should_not_receive(:perform)
    end
  end

end
