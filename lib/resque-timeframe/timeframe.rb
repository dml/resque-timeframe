require 'time'

module Resque
  module Plugins
    module Timeframe

      WEEK = [ :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday ].freeze

      def week
        WEEK
      end

      def settings
        @options ||= WEEK.inject({:default => true, :recurrent => 60}) {|c,v| c.merge({v => true})}
      end

      def timeframe(options = {})
        options.map do |param,value|
          case param
            when Array
              param.map {|k| timeframe({k => value}) }
            when String
              timeframe({param.to_sym => value})
            when Symbol
              settings.merge!({param => value})
            else
              # 
          end
        end
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

      def time_at(hr)
        t = Time.now
        if (0..23).include?(hr)
          Time.mktime(t.year, t.month, t.day, hr, 0, 0)
        else
          Time.mktime(t.year, t.month, t.day + 1, 0, 0, 0)
        end
      end

      def range(date_range)
        case date_range.begin
          when Integer
            time_at(date_range.begin)..time_at(date_range.end)
          when String
            Time.parse(date_range.begin)..Time.parse(date_range.end)
          when Time
            date_range
          else
            time_at(0)..time_at(24)
        end
      end

      def before_perform_timeframe(*args)
        unless allowed_at?(week[Time.new.wday])
          Resque.enqueue_in(settings[:recurrent], self, *args) if settings[:recurrent]

          raise Resque::Job::DontPerform
        end
      end

    end

    class TimeframedJob
      extend Timeframe
    end
  end
end
