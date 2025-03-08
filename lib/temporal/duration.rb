# frozen_string_literal: true

require "matrix"

module Temporal
  class Duration
    FIELDS = %i[years months weeks days hours minutes seconds milliseconds microseconds nanoseconds]
    attr_reader(*FIELDS)

    class << self
      def from(arg)
        case arg
        when Duration
          Duration.new(
            arg.years,
            arg.months,
            arg.weeks,
            arg.days,
            arg.hours,
            arg.minutes,
            arg.seconds,
            arg.milliseconds,
            arg.microseconds,
            arg.nanoseconds
          )
        when Hash
          Duration.new(
            arg[:years] || 0,
            arg[:months] || 0,
            arg[:weeks] || 0,
            arg[:days] || 0,
            arg[:hours] || 0,
            arg[:minutes] || 0,
            arg[:seconds] || 0,
            arg[:milliseconds] || 0,
            arg[:microseconds] || 0,
            arg[:nanoseconds] || 0
          )
        when String
          iso8601 = ISO8601Duration.new(arg).to_h
          sign = iso8601.delete(:sign)
          duration_values = iso8601.transform_values do |val|
            val.nil? ? nil : val * sign
          end
          Duration.from(duration_values)
        else
          raise ArgumentError.new("Argument must be a Duration, Hash or String")
        end
      end

      private

      def from_nanoseconds(nanoseconds)
        magnitude, sign = if nanoseconds.negative?
          [nanoseconds.abs, -1]
        else
          [nanoseconds, 1]
        end
        non_calendar_totals = [24 * 60 * 60 * 1e9, 60 * 60 * 1e9, 60 * 1e9, 1e9, 1e6, 1e3, 1]
        non_calendar_values = non_calendar_totals.map do |total|
          value, magnitude = magnitude.divmod(total)
          sign * value
        end
        Duration.new(0, 0, 0, *non_calendar_values)
      end
    end

    def initialize(years = 0, months = 0, weeks = 0, days = 0, hours = 0, minutes = 0, seconds = 0, milliseconds = 0, microseconds = 0, nanoseconds = 0)
      args = [years, months, weeks, days, hours, minutes, seconds, milliseconds, microseconds, nanoseconds]
      unless args.all? { _1.is_a? Integer }
        raise RangeError.new("Arguments must be integers")
      end

      check_sign! args

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

    def sign
      check_sign!(fields)
    end

    def blank?
      sign == 0
    end

    def abs
      Duration.new(*fields.map(&:abs))
    end

    def add(other)
      if calendar? || other.calendar?
        raise RangeError.new("For years, months, or weeks arithmetic, use date arithmetic relative to a starting point")
      else
        Duration.send(:from_nanoseconds, (total_nanoseconds + other.total_nanoseconds))
      end
    end

    def +(other) = add(other)

    def ==(other)
      if fields == other.fields
        true
      elsif calendar? || other.calendar?
        raise RangeError.new("A starting point is required for years, months, or weeks comparison")
      else
        total_nanoseconds == other.total_nanoseconds
      end
    end

    def negated
      Duration.new(*fields.map(&:-@))
    end

    def -@ = negated

    def +@ = Duration.new(*fields)

    def subtract(other)
      add(other.negated)
    end

    def -(other) = subtract(other)

    def to_s
      ISO8601Duration.new(
        sign: (sign == -1) ? -1 : 1,
        years: years.abs,
        months: months.abs,
        weeks: weeks.abs,
        days: days.abs,
        hours: hours.abs,
        minutes: minutes.abs,
        seconds: seconds.abs,
        milliseconds: milliseconds.abs,
        microseconds: microseconds.abs,
        nanoseconds: nanoseconds.abs
      ).to_s
    end

    def to_json = to_s

    def with(arg)
      unless (arg.keys - FIELDS).empty?
        raise ArgumentError.new("Unrecognised attributes: #{(arg.keys - FIELDS).join(", ")}")
      end

      Duration.new(
        arg[:years] || years,
        arg[:months] || months,
        arg[:weeks] || weeks,
        arg[:days] || days,
        arg[:hours] || hours,
        arg[:minutes] || minutes,
        arg[:seconds] || seconds,
        arg[:milliseconds] || milliseconds,
        arg[:microseconds] || microseconds,
        arg[:nanoseconds] || nanoseconds
      )
    end

    private

    def check_sign!(args)
      if args.all? { _1 == 0 }
        0
      elsif args.all? { _1 >= 0 }
        1
      elsif args.all? { _1 <= 0 }
        -1
      else
        raise RangeError.new("Mixed-sign values not allowed as duration fields")
      end
    end

    protected

    def fields
      [years, months, weeks, days, hours, minutes, seconds, milliseconds, microseconds, nanoseconds]
    end

    def calendar?
      years.nonzero? || months.nonzero? || weeks.nonzero?
    end

    def total_nanoseconds
      non_calendar_totals = Vector[24 * 60 * 60 * 1e9, 60 * 60 * 1e9, 60 * 1e9, 1e9, 1e6, 1e3, 1]
      non_calendar_values = Vector[days, hours, minutes, seconds, milliseconds, microseconds, nanoseconds]
      non_calendar_totals.inner_product(non_calendar_values)
    end
  end
end
