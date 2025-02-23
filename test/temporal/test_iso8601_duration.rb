# frozen_string_literal: true

require "temporal/iso8601_duration"

module Temporal
  class ISO8601DurationTest < Minitest::Test
    def test_to_h
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
          ISO8601Duration.new(test_case).to_h
        end
      end

      duration = ISO8601Duration.new("P12Y").to_h
      assert_equal 12, duration[:years]
      assert_nil duration[:months]

      duration = ISO8601Duration.new("+P1Y").to_h
      assert_equal 1, duration[:years]
      assert_nil duration[:months]

      duration = ISO8601Duration.new("-P1Y").to_h
      assert_equal(-1, duration[:years])
      assert_nil duration[:months]

      duration = ISO8601Duration.new("P12M").to_h
      assert_nil duration[:years]
      assert_equal 12, duration[:months]
      assert_nil duration[:weeks]

      duration = ISO8601Duration.new("P2Y1M").to_h
      assert_equal 2, duration[:years]
      assert_equal 1, duration[:months]

      duration = ISO8601Duration.new("P12W").to_h
      assert_nil duration[:months]
      assert_equal 12, duration[:weeks]
      assert_nil duration[:days]

      duration = ISO8601Duration.new("P2M1W").to_h
      assert_equal 2, duration[:months]
      assert_equal 1, duration[:weeks]

      duration = ISO8601Duration.new("P3Y2M1W").to_h
      assert_equal 3, duration[:years]
      assert_equal 2, duration[:months]
      assert_equal 1, duration[:weeks]

      duration = ISO8601Duration.new("P12D").to_h
      assert_nil duration[:weeks]
      assert_equal 12, duration[:days]
      assert_nil duration[:seconds]

      duration = ISO8601Duration.new("P2W1D").to_h
      assert_equal 2, duration[:weeks]
      assert_equal 1, duration[:days]

      duration = ISO8601Duration.new("P3M2W1D").to_h
      assert_equal 3, duration[:months]
      assert_equal 2, duration[:weeks]
      assert_equal 1, duration[:days]

      duration = ISO8601Duration.new("PT12H").to_h
      assert_nil duration[:days]
      assert_equal 12, duration[:hours]
      assert_nil duration[:minutes]

      duration = ISO8601Duration.new("P2DT1H").to_h
      assert_equal 2, duration[:days]
      assert_equal 1, duration[:hours]

      duration = ISO8601Duration.new("PT12M").to_h
      assert_nil duration[:months]
      assert_nil duration[:hours]
      assert_equal 12, duration[:minutes]
      assert_nil duration[:seconds]

      duration = ISO8601Duration.new("P2MT1M").to_h
      assert_equal 2, duration[:months]
      assert_equal 1, duration[:minutes]

      duration = ISO8601Duration.new("PT12S").to_h
      assert_nil duration[:minutes]
      assert_equal 12, duration[:seconds]
      assert_nil duration[:milliseconds]

      duration = ISO8601Duration.new("PT1.2S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 200, duration[:milliseconds]
      assert_nil duration[:microseconds]
      assert_nil duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.23S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 230, duration[:milliseconds]
      assert_nil duration[:microseconds]
      assert_nil duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.234S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_nil duration[:microseconds]
      assert_nil duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.2345S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_equal 500, duration[:microseconds]
      assert_nil duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.23456S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_equal 560, duration[:microseconds]
      assert_nil duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.234567S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_equal 567, duration[:microseconds]
      assert_nil duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.000000000S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 0, duration[:milliseconds]
      assert_equal 0, duration[:microseconds]
      assert_equal 0, duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.2345678S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_equal 567, duration[:microseconds]
      assert_equal 800, duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.23456789S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_equal 567, duration[:microseconds]
      assert_equal 890, duration[:nanoseconds]

      duration = ISO8601Duration.new("PT1.234567898S").to_h
      assert_equal 1, duration[:seconds]
      assert_equal 234, duration[:milliseconds]
      assert_equal 567, duration[:microseconds]
      assert_equal 898, duration[:nanoseconds]

      duration = ISO8601Duration.new("P1Y2M3W4DT5H6M7.008009010S").to_h
      assert_equal 1, duration[:years]
      assert_equal 2, duration[:months]
      assert_equal 3, duration[:weeks]
      assert_equal 4, duration[:days]
      assert_equal 5, duration[:hours]
      assert_equal 6, duration[:minutes]
      assert_equal 7, duration[:seconds]
      assert_equal 8, duration[:milliseconds]
      assert_equal 9, duration[:microseconds]
      assert_equal 10, duration[:nanoseconds]
    end
  end
end
