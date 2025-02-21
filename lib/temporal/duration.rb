# frozen_string_literal: true

require "matrix"

module Temporal
  class Duration
    attr_reader :years, :months, :weeks, :days, :hours, :minutes, :seconds, :milliseconds, :microseconds, :nanoseconds

    def initialize(years = 0, months = 0, weeks = 0, days = 0, hours = 0, minutes = 0, seconds = 0, milliseconds = 0, microseconds = 0, nanoseconds = 0)
      args = [years, months, weeks, days, hours, minutes, seconds, milliseconds, microseconds, nanoseconds]
      unless args.all? { _1.is_a? Integer }
        raise RangeError.new("Arguments must be integers")
      end

      unless args.all? { _1 >= 0 } || args.all? { _1 <= 0 }
        raise RangeError.new("Mixed-sign values not allowed as duration fields")
      end

      calendar_args = [years, months, weeks]
      unless calendar_args.all? { _1 < 2**32 }
        raise RangeError.new("Calendar arguments (years, months, weeks) must be < 2**32")
      end

      non_calendar_args = Vector[days, hours, minutes, seconds, milliseconds, microseconds, nanoseconds]
      in_seconds = Vector[24 * 60 * 60, 60 * 60, 60, 1, 1e-3, 1e-6, 1e-9]
      non_calendar_duration = non_calendar_args.inner_product(in_seconds)
      unless non_calendar_duration < 2**53
        raise RangeError.new("Non-calendar duration in seconds must be < 2**53")
      end

      @years = years
      @months = months
      @weeks = weeks
      @days = days
      @hours = hours
      @minutes = minutes
      @seconds = seconds
      @milliseconds = milliseconds
      @microseconds = microseconds
      @nanoseconds = nanoseconds
    end
  end
end
