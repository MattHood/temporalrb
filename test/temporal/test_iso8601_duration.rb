# frozen_string_literal: true

require "temporal/iso8601_duration"
require "debug"

module Temporal
  class ISO8601DurationTest < Minitest::Test
    # TODO Sign should be returned separately, not applied to values. That can be done in Duration.
    def test_initialize_invalid
      assert_raises ArgumentError do
        ISO8601Duration.new(Object.new)
      end
    end

    def test_initialize_to_zero
      duration = ISO8601Duration.new
      assert_equal 1, duration.sign
      assert_equal 0, duration.years
      assert_equal 0, duration.months
      assert_equal 0, duration.weeks
      assert_equal 0, duration.days
      assert_equal 0, duration.hours
      assert_equal 0, duration.minutes
      assert_equal 0, duration.seconds
      assert_equal 0, duration.milliseconds
      assert_equal 0, duration.microseconds
      assert_equal 0, duration.nanoseconds
    end

    def test_initialize_with_string
      invalid_cases = [
        "",
        "+",
        "-",
        "P",
        "+P",
        "-P",
        "P1",
        "PY",
        "PM",
        "P1YM",
        "P1M1Y",
        "P1Y1MW",
        "P1Y1M1WD",
        "PT",
        "P1YT",
        "PTH",
        "PT1HM",
        "PT1H1MS",
        "PT1.S",
        "PT1.0000000000S"
      ]
      invalid_cases.each do |test_case|
        assert_raises RangeError, "Duration string #{test_case} should raise a RangeError" do
          ISO8601Duration.new(test_case)
        end
      end

      duration = ISO8601Duration.new("P12Y")
      assert_equal 1, duration.sign
      assert_equal 12, duration.years
      assert_nil duration.months

      duration = ISO8601Duration.new("+P1Y")
      assert_equal 1, duration.sign
      assert_equal 1, duration.years
      assert_nil duration.months

      duration = ISO8601Duration.new("-P1Y")
      assert_equal(-1, duration.sign)
      assert_equal 1, duration.years
      assert_nil duration.months

      duration = ISO8601Duration.new("P12M")
      assert_nil duration.years
      assert_equal 12, duration.months
      assert_nil duration.weeks

      duration = ISO8601Duration.new("P2Y1M")
      assert_equal 2, duration.years
      assert_equal 1, duration.months

      duration = ISO8601Duration.new("P12W")
      assert_nil duration.months
      assert_equal 12, duration.weeks
      assert_nil duration.days

      duration = ISO8601Duration.new("P2M1W")
      assert_equal 2, duration.months
      assert_equal 1, duration.weeks

      duration = ISO8601Duration.new("P3Y2M1W")
      assert_equal 3, duration.years
      assert_equal 2, duration.months
      assert_equal 1, duration.weeks

      duration = ISO8601Duration.new("P12D")
      assert_nil duration.weeks
      assert_equal 12, duration.days
      assert_nil duration.seconds

      duration = ISO8601Duration.new("P2W1D")
      assert_equal 2, duration.weeks
      assert_equal 1, duration.days

      duration = ISO8601Duration.new("P3M2W1D")
      assert_equal 3, duration.months
      assert_equal 2, duration.weeks
      assert_equal 1, duration.days

      duration = ISO8601Duration.new("PT12H")
      assert_nil duration.days
      assert_equal 12, duration.hours
      assert_nil duration.minutes

      duration = ISO8601Duration.new("P2DT1H")
      assert_equal 2, duration.days
      assert_equal 1, duration.hours

      duration = ISO8601Duration.new("PT12M")
      assert_nil duration.months
      assert_nil duration.hours
      assert_equal 12, duration.minutes
      assert_nil duration.seconds

      duration = ISO8601Duration.new("P2MT1M")
      assert_equal 2, duration.months
      assert_equal 1, duration.minutes

      duration = ISO8601Duration.new("PT12S")
      assert_nil duration.minutes
      assert_equal 12, duration.seconds
      assert_nil duration.milliseconds

      duration = ISO8601Duration.new("PT1.2S")
      assert_equal 1, duration.seconds
      assert_equal 200, duration.milliseconds
      assert_nil duration.microseconds
      assert_nil duration.nanoseconds

      duration = ISO8601Duration.new("PT1.23S")
      assert_equal 1, duration.seconds
      assert_equal 230, duration.milliseconds
      assert_nil duration.microseconds
      assert_nil duration.nanoseconds

      duration = ISO8601Duration.new("PT1.234S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_nil duration.microseconds
      assert_nil duration.nanoseconds

      duration = ISO8601Duration.new("PT1.2345S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_equal 500, duration.microseconds
      assert_nil duration.nanoseconds

      duration = ISO8601Duration.new("PT1.23456S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_equal 560, duration.microseconds
      assert_nil duration.nanoseconds

      duration = ISO8601Duration.new("PT1.234567S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_equal 567, duration.microseconds
      assert_nil duration.nanoseconds

      duration = ISO8601Duration.new("PT1.000000000S")
      assert_equal 1, duration.seconds
      assert_equal 0, duration.milliseconds
      assert_equal 0, duration.microseconds
      assert_equal 0, duration.nanoseconds

      duration = ISO8601Duration.new("PT1.2345678S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_equal 567, duration.microseconds
      assert_equal 800, duration.nanoseconds

      duration = ISO8601Duration.new("PT1.23456789S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_equal 567, duration.microseconds
      assert_equal 890, duration.nanoseconds

      duration = ISO8601Duration.new("PT1.234567898S")
      assert_equal 1, duration.seconds
      assert_equal 234, duration.milliseconds
      assert_equal 567, duration.microseconds
      assert_equal 898, duration.nanoseconds

      duration = ISO8601Duration.new("P1Y2M3W4DT5H6M7.008009010S")
      assert_equal 1, duration.years
      assert_equal 2, duration.months
      assert_equal 3, duration.weeks
      assert_equal 4, duration.days
      assert_equal 5, duration.hours
      assert_equal 6, duration.minutes
      assert_equal 7, duration.seconds
      assert_equal 8, duration.milliseconds
      assert_equal 9, duration.microseconds
      assert_equal 10, duration.nanoseconds

      duration = ISO8601Duration.new("-P1Y2M3W4DT5H6M7.008009010S")
      assert_equal(-1, duration.sign)
      assert_equal 1, duration.years
      assert_equal 2, duration.months
      assert_equal 3, duration.weeks
      assert_equal 4, duration.days
      assert_equal 5, duration.hours
      assert_equal 6, duration.minutes
      assert_equal 7, duration.seconds
      assert_equal 8, duration.milliseconds
      assert_equal 9, duration.microseconds
      assert_equal 10, duration.nanoseconds
    end

    # TODO Test refusing mixed signs
    def test_initialize_with_hash
      assert_raises ArgumentError do
        ISO8601Duration.new(foo: 1)
      end

      duration = ISO8601Duration.new({})
      assert_equal 1, duration.sign
      assert_equal 0, duration.years
      assert_equal 0, duration.months
      assert_equal 0, duration.weeks
      assert_equal 0, duration.days
      assert_equal 0, duration.hours
      assert_equal 0, duration.minutes
      assert_equal 0, duration.seconds
      assert_equal 0, duration.milliseconds
      assert_equal 0, duration.microseconds
      assert_equal 0, duration.nanoseconds

      duration = ISO8601Duration.new({
        sign: -1,
        years: 1,
        months: 2,
        weeks: 3,
        days: 4,
        hours: 5,
        minutes: 6,
        seconds: 7,
        milliseconds: 8,
        microseconds: 9,
        nanoseconds: 10
      })
      assert_equal(-1, duration.sign)
      assert_equal 1, duration.years
      assert_equal 2, duration.months
      assert_equal 3, duration.weeks
      assert_equal 4, duration.days
      assert_equal 5, duration.hours
      assert_equal 6, duration.minutes
      assert_equal 7, duration.seconds
      assert_equal 8, duration.milliseconds
      assert_equal 9, duration.microseconds
      assert_equal 10, duration.nanoseconds
    end

    def to_h
      duration = Duration.new
      duration.sign = -1
      duration.years = 1
      duration.months = 2
      duration.weeks = 3
      duration.days = 4
      duration.hours = 5
      duration.minutes = 6
      duration.seconds = 7
      duration.milliseconds = 8
      duration.microseconds = 9
      duration.nanoseconds = 10

      assert_equal({
        sign: -1,
        years: 1,
        months: 2,
        weeks: 3,
        days: 4,
        hours: 5,
        minutes: 6,
        seconds: 7,
        milliseconds: 8,
        microseconds: 9,
        nanoseconds: 10
      }, duration.to_h)
    end

    def test_to_s
      duration = ISO8601Duration.new("P1Y1M1W1DT1H1M1.111111111S")
      assert_equal "P1Y1M1W1DT1H1M1.111111111S", duration.to_s

      duration = ISO8601Duration.new("-P1Y1M1W1DT1H1M1.111111111S")
      assert_equal "-P1Y1M1W1DT1H1M1.111111111S", duration.to_s

      duration = ISO8601Duration.new("+P1Y1M1W1DT1H1M1.111111111S")
      assert_equal "P1Y1M1W1DT1H1M1.111111111S", duration.to_s

      duration = ISO8601Duration.new("P123Y456M789W987DT654H321M234.567898765S")
      assert_equal "P123Y456M789W987DT654H321M234.567898765S", duration.to_s
    end
  end
end
