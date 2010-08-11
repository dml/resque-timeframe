require File.join(File.dirname(__FILE__) + '/../spec_helper')

describe Resque::Plugins::TimeframeJob do
  it "should follow the convention" do
    Resque::Plugin.lint(Resque::Plugins::TimeframeJob)
  end



end
