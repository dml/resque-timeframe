require 'rubygems'
require 'spec/autorun'
require 'mocha'

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'resque-timeframe'

#
# make sure we can run redis
#

if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end


#
# start our own redis when the tests start,
# kill it when they end
#

at_exit do
  next if $!

  exit_code = Spec::Runner.run

  pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
  puts "Killing test redis server [#{pid}]..."
  `rm -f #{dir}/dump.rdb`
  Process.kill("KILL", pid.to_i)
  exit exit_code
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
Resque.redis = 'localhost:9736'


#
# job classes
#
class AllowedByDefaultTimeframeJob < Resque::Plugins::TimeframedJob
  @queue = :timeframed_queue
  def self.perform(args); end
end

class RestrictedByDefaultTimeframeJob < Resque::Plugins::TimeframedJob
  timeframe :default => false

  @queue = :timeframed_queue
  def self.perform(args); end
end

class WorkingDaysTimeframeJob < Resque::Plugins::TimeframedJob
  timeframe week - [:saturday, :sunday] => 0..9 # 24 hour format

  @queue = :timeframed_queue
  def self.perform(args); end
end

class DisabledDayTimeframeJob < Resque::Plugins::TimeframedJob
  timeframe :sunday => true

  @queue = :timeframed_queue
  def self.perform(args); end
end

class RegularWeekRestrictionJob < Resque::Plugins::TimeframedJob
  timeframe :monday     => 0..11    # 0 a.m. .. 11 a.m.
  timeframe :tuesday    => 14..23   # 14 p.m. .. 23 p.m.
  timeframe :wednesday  => 0..11
  timeframe :thursday   => '9:30'..'11:30'
  timeframe :friday     => 0..11
  timeframe :saturday   => true
  timeframe :sunday     => false

  @queue = :timeframed_queue

  def self.perform(args)
  end
end
