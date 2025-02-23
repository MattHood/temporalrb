# frozen_string_literal: true

require "temporal/duration"

module Temporal
  class DurationTest < Minitest::Test
    def test_initialize
      duration = Duration.new
      assert_equal 0, duration.years

      duration = Duration.new(10)
      assert_equal 10, duration.years
      assert_equal 0, duration.months

      duration = Duration.new(10, 8)
      assert_equal 8, duration.months
      assert_equal 0, duration.weeks

      duration = Duration.new(10, 8, 6)
      assert_equal 6, duration.weeks
      assert_equal 0, duration.days

      duration = Duration.new(10, 8, 6, 4)
      assert_equal 4, duration.days
      assert_equal 0, duration.hours

      duration = Duration.new(10, 8, 6, 4, 2)
      assert_equal 2, duration.hours
      assert_equal 0, duration.minutes

      duration = Duration.new(10, 8, 6, 4, 2, 1)
      assert_equal 1, duration.minutes
      assert_equal 0, duration.seconds

      duration = Duration.new(10, 8, 6, 4, 2, 1, 3)
      assert_equal 3, duration.seconds
      assert_equal 0, duration.milliseconds

      duration = Duration.new(10, 8, 6, 4, 2, 1, 3, 5)
      assert_equal 5, duration.milliseconds
      assert_equal 0, duration.microseconds

      duration = Duration.new(10, 8, 6, 4, 2, 1, 3, 5, 7)
      assert_equal 7, duration.microseconds
      assert_equal 0, duration.nanoseconds

      duration = Duration.new(10, 8, 6, 4, 2, 1, 3, 5, 7, 9)
      assert_equal 7, duration.microseconds
      assert_equal 9, duration.nanoseconds
    end

    def test_intialize_with_non_integer_argument
      cases = [
        [0.1],
        [0, 0.1],
        [0, 0, 0.1],
        [0, 0, 0, 0.1],
        [0, 0, 0, 0, 0.1],
        [0, 0, 0, 0, 0, 0.1],
        [0, 0, 0, 0, 0, 0, 0.1],
        [0, 0, 0, 0, 0, 0, 0, 0.1],
        [0, 0, 0, 0, 0, 0, 0, 0, 0.1],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1]
      ]
      cases.each do |args|
        assert_raises RangeError do
          Duration.new(*args)
        end
      end
    end

    def test_initialize_with_oversized_calendar_argument
      cases = [
        [2**32],
        [0, 2**32],
        [0, 0, 2**32]
      ]
      cases.each do |args|
        assert_raises RangeError do
          Duration.new(*args)
        end
      end
    end

    def test_initialize_with_oversized_non_calendar_argument
      day = 24 * 60 * 60
      cases = [
        [0, 0, 0, 2**53 / day + 1],
        [0, 0, 0, 0, 0, 0, 2**53],
        [0, 0, 0, 0, 0, 0, 0, 2**53 * 1e3]
      ]
      cases.each do |args|
        assert_raises RangeError do
          Duration.new(*args)
        end
      end
    end

    def test_initialize_with_mixed_signs
      assert_raises RangeError do
        Duration.new(1, 0, -1, 0, 4, 0, -3, 0, 2, 0)
      end
    end

    def test_from_duration
      duration = Duration.from(
        Duration.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
      )
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

    def test_from_hash
      duration = Duration.from(
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
      )
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

    def test_from_invalid
      assert_raises ArgumentError do
        Duration.from(Object.new)
      end
    end

    def test_from_iso8601_duration
      duration = Duration.from("P1Y2M40W4DT5H6M678.008009010S")
      assert_equal 1, duration.years
      assert_equal 2, duration.months
      assert_equal 40, duration.weeks
      assert_equal 4, duration.days
      assert_equal 5, duration.hours
      assert_equal 6, duration.minutes
      assert_equal 678, duration.seconds
      assert_equal 8, duration.milliseconds
      assert_equal 9, duration.microseconds
      assert_equal 10, duration.nanoseconds
    end

    def test_sign
      duration = Duration.new(1)
      assert_equal 1, duration.sign

      duration = Duration.new(1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
      assert_equal 1, duration.sign

      duration = Duration.new(-1)
      assert_equal(-1, duration.sign)

      duration = Duration.new(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
      assert_equal(-1, duration.sign)

      duration = Duration.new
      assert_equal 0, duration.sign
    end

    def test_blank
      duration = Duration.new(1)
      assert_equal false, duration.blank?

      duration = Duration.new
      assert_equal true, duration.blank?
    end

    def test_abs
      duration = Duration.new(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1).abs
      %i[years months weeks days hours minutes seconds milliseconds microseconds nanoseconds].each do |unit|
        assert_equal 1, duration.public_send(unit)
      end

      duration = Duration.new(1, 1, 1, 1, 1, 1, 1, 1, 1, 1).abs
      %i[years months weeks days hours minutes seconds milliseconds microseconds nanoseconds].each do |unit|
        assert_equal 1, duration.public_send(unit)
      end

      duration = Duration.new.abs
      %i[years months weeks days hours minutes seconds milliseconds microseconds nanoseconds].each do |unit|
        assert_equal 0, duration.public_send(unit)
      end
    end

    def test_equal
      assert_raises RangeError do
        Duration.from("P1Y") == Duration.new(0, 12)
      end

      assert_equal Duration.from("P1D"), Duration.new(0, 0, 0, 1)
      refute_equal Duration.from("P1D"), Duration.new(0, 0, 0, 2)
      assert_equal Duration.from("P1Y"), Duration.new(1)

      assert_equal Duration.from("P1D"), Duration.from("PT24H")
      assert_equal Duration.from("PT1H"), Duration.from("PT60M")
      assert_equal Duration.from("PT1M"), Duration.from("PT60S")
    end

    def test_add
      calendar_cases = [
        [1],
        [0, 1],
        [0, 0, 1]
      ]
      non_calendar_case = [0, 0, 0, 1]
      calendar_cases.each do |calendar_case|
        assert_raises RangeError do
          duration_to_add = Duration.new(*non_calendar_case)
          Duration.new(*calendar_case).add(duration_to_add)
        end

        assert_raises RangeError do
          duration_to_add = Duration.new(*calendar_case)
          Duration.new(*non_calendar_case).add(duration_to_add)
        end
      end

      assert_equal Duration.from("P3D"), Duration.from("P1D").add(Duration.from("P2D"))
      assert_equal Duration.from("P1DT4H"), Duration.from("PT20H").add(Duration.from("PT8H"))
      assert_equal Duration.from("P1DT4H"), Duration.from("PT20H").add(Duration.from("PT6H60M3600S"))

      assert_equal Duration.from("P3D"), Duration.from("P1D") + Duration.from("P2D")
    end

    def test_negated
      all_ones = Duration.new(1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
      all_zeros = Duration.new
      all_minus_ones = Duration.new(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1)

      assert_equal all_ones, all_minus_ones.negated
      assert_equal all_minus_ones, all_ones.negated
      assert_equal all_zeros, all_zeros.negated

      assert_equal all_ones.negated, -all_ones
    end

    def test_identity
      duration = Duration.from("P1Y1M1W1DT1H1M1S")
      assert_equal duration, +duration
    end
  end
end
