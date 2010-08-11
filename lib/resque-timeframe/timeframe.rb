require 'time'

module Resque
  module Plugins
    module Timeframe

      WEEK = [ :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday ].freeze

      def week
        WEEK
      end

      def settings
        @options ||= WEEK.inject({:default => true}) {|c,v| c.merge({v => true})}
      end

      def timeframe(options={})
        settings.merge!(options)
      end

      def allowed_at?(weekday)
        case settings[weekday]
          when Range
            range(settings[weekday]).include?(Time.now)
          when FalseClass, TrueClass
            settings[weekday] && settings[:default]
          else
            settings[:default]
        end
      end

      def range(date_range)
        case date_range.begin
          when Integer
            time_at = lambda {|hr| Time.mktime(Time.new.year, Time.new.month, Time.new.day, hr, 0, 0)} 
            time_at.call(date_range.begin)..time_at.call(date_range.end)
          when String
            Time.parse(date_range.begin)..Time.parse(date_range.end)
          when Time
            date_range
          else
            Time.parse("00:00")..Time.parse("23:59")
        end
      end

      def before_perform_timeframe(*args)
        raise Resque::Job::DontPerform unless allowed_at?(week[Time.new.wday])
      end

    end

    class TimeframedJob
      extend Timeframe
    end
  end
end
