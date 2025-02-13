# frozen_string_literal: true

require "temporal/instant"

module Temporal
  class InstantTest < Minitest::Test
    def test_new
      nanoseconds = 1_000_000_000
      instant = Instant.new(nanoseconds)
      assert_equal nanoseconds, instant.epoch_nanoseconds
    end

    def test_from
      old_instant = Instant.new(1_234)
      new_instant = Instant.from(old_instant)
      assert_equal 1_234, new_instant.epoch_nanoseconds

      utc_instant = Instant.from("2019-03-30T00:45Z")
      nanoseconds = 1553906700000000000
      assert_equal nanoseconds, utc_instant.epoch_nanoseconds

      assert_raises ArgumentError do
        Instant.from(true)
      end
    end

    def test_from_epoch_nanoseconds
      nanoseconds = 1_000_000_000
      instant = Instant.from_epoch_nanoseconds(nanoseconds)
      assert_equal nanoseconds, instant.epoch_nanoseconds
    end

    def test_from_epoch_milliseconds
      milliseconds = 1_234_567
      nanoseconds = milliseconds * 1000 * 1000
      instant = Instant.from_epoch_milliseconds(milliseconds)
      assert_equal nanoseconds, instant.epoch_nanoseconds
    end

    def test_epoch_milliseconds
      nanoseconds = 1_000_000_000
      milliseconds = 1_000
      instant = Instant.new(nanoseconds)
      assert_equal milliseconds, instant.epoch_milliseconds
    end

    def test_compare
      assert_equal(-1, Instant.compare(Instant.new(1_000), Instant.new(2_000)))
      assert_equal 0, Instant.compare(Instant.new(2_000), Instant.new(2_000))
      assert_equal 1, Instant.compare(Instant.new(2_000), Instant.new(1_000))
    end

    def test_round
      t = Data.define(:input, :args, :output)
      test_cases = [
        # Single unit argument with default multiplier, rounding mode
        t["2024-01-01T08:15:36Z", :hour, "2024-01-01T08:00:00Z"],
        t["2024-01-01T08:15:36Z", :minute, "2024-01-01T08:16:00Z"],
        t["2024-01-01T08:15:36.500Z", :second, "2024-01-01T08:15:37Z"],
        t["2024-01-01T08:15:36.5004Z", :millisecond, "2024-01-01T08:15:36.5Z"],
        t["2024-01-01T08:15:36.0001007Z", :microsecond, "2024-01-01T08:15:36.000101Z"],
        t["2024-01-01T08:15:36.000100201Z", :nanosecond, "2024-01-01T08:15:36.000100201Z"],

        # Keyword arguments
        t["2024-01-01T08:15:36Z", {smallest_unit: :hour}, "2024-01-01T08:00:00Z"],
        t["2024-01-01T08:15:36Z", {smallest_unit: :hour, rounding_increment: 2, rounding_mode: :ceil}, "2024-01-01T10:00:00Z"],
        t["2024-01-01T08:17:36Z", {smallest_unit: :minute, rounding_increment: 3, rounding_mode: :floor}, "2024-01-01T08:15:00Z"],
        t["2024-01-01T08:17:37Z", {smallest_unit: :second, rounding_increment: 4, rounding_mode: :expand}, "2024-01-01T08:17:40Z"],
        t["2024-01-01T08:15:36.504Z", {smallest_unit: :millisecond, rounding_increment: 5, rounding_mode: :trunc}, "2024-01-01T08:15:36.500Z"],
        t["2024-01-01T08:15:36.000105Z", {smallest_unit: :microsecond, rounding_increment: 30, rounding_mode: :half_ceil}, "2024-01-01T08:15:36.000120Z"],
        t["2024-01-01T08:15:36.000100249Z", {smallest_unit: :nanosecond, rounding_increment: 100, rounding_mode: :half_floor}, "2024-01-01T08:15:36.000100200Z"],
        t["2024-01-01T08:15:36.000105Z", {smallest_unit: :microsecond, rounding_increment: 30, rounding_mode: :half_expand}, "2024-01-01T08:15:36.000120Z"],
        t["2024-01-01T08:15:36.000100249Z", {smallest_unit: :nanosecond, rounding_increment: 100, rounding_mode: :half_trunc}, "2024-01-01T08:15:36.000100200Z"]
      ]

      test_cases.each do |test_case|
        input = Instant.from(test_case.input)
        output = if test_case.args.is_a?(Hash)
          input.round(**test_case.args)
        else
          input.round(test_case.args)
        end
        expected = Instant.from(test_case.output)
        assert_equal expected.epoch_nanoseconds, output.epoch_nanoseconds
      end
    end
  end
end
