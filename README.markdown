resque-timeframe
===============

Resque Timeframe is a plugin for the [Resque][0] queueing system (http://github.com/defunkt/resque).
It allows to limit job execution in a timeframe. Sometimes we need to run huge tasks and this is not good at business time.
For example, archive operation could be run at any time excluding prime time. It possible to schedule tasks at night or weekends, but this is not flexible. Some times it is not possible to calculate how many archivation tasks you can schedule at the range of time. Using this plugin it possible to define timeframes (even possible to describe a week) and schedule tasks into queue. Resque would not execute jobs if it out of timeframe.

Resque Timeframe requires Resque 1.7.0.

Install
-------

  sudo gem install resque-timeframe

To use
------

Simpliest Timeframed job works like a regular job there each day of week allowed by default

  class AllowedByDefaultTimeframeJob < Resque::Plugins::TimeframedJob
    timeframe :default => true # deafult value

    @queue = :timeframed_queue

    def self.perform(args); end
  end

To define timeframe possible to using week day name

  class ArchiveJob < Resque::Plugins::TimeframedJob
    timeframe :monday     => false            # do not allow execution at Monday
    timeframe :tuesday    => 14..22           # from 14 p.m. till 22 p.m.
    timeframe :wednesday  => 0..24            # full day
    timeframe :thursday   => '9:30'..'11:30'  # 24-hours format able to be parsed like Time.parse("23:59")
    timeframe :friday     => '17:30'..'23:59' 
    timeframe :saturday   => true             # same as 0..24
    timeframe :sunday     => true

    @queue = :timeframed_queue

    def self.perform(args)
    end
  end

or like this

  class ArchiveJob < Resque::Plugins::TimeframedJob
    timeframe :default => false
    timeframe [:saturday, :sunday] => true    # allow execution only at weekends

    @queue = :timeframed_queue

    def self.perform(args); end
  end

  class ArchiveJob < Resque::Plugins::TimeframedJob
    timeframe week - [:saturday, :sunday] => 0..9

    @queue = :timeframed_queue

    def self.perform(args); end
  end


All timeframed jobs would be delayed in 60 seconds if job out of timeframe. Delay could be configured of set to false. If delay set to false all jobs would be removed from queue.

  class Job < Resque::Plugins::TimeframedJob
    timeframe :recurrent => 900 # in seconds

    @queue = :timeframed_queue
    def self.perform(args); end
  end

or

  class HaveAChanceJob < Resque::Plugins::TimeframedJob
    timeframe :recurrent => false

    @queue = :timeframed_queue
    def self.perform(args); end
  end



Copyright
---------
Copyright (c) 2010 Dmitry Larkin (at [Railsware][3] for [Ratepoint][4])



[0]: http://github.com/defunkt/resque
[1]: http://help.github.com/forking/
[2]: http://github.com/dml/resque-timeframe/issues
[3]: http://railsware.com
[4]: http://ratepoint.com
[5]: http://github.com/bvandenbos/resque-scheduler
