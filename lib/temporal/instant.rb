require "date"

module Temporal
  class Instant
    attr_reader :epoch_nanoseconds

    class << self
      def from_epoch_nanoseconds(epoch_nanoseconds)
        new(epoch_nanoseconds)
      end

      def from_epoch_milliseconds(epoch_milliseconds)
        epoch_nanoseconds = epoch_milliseconds * 1000 * 1000
        new(epoch_nanoseconds)
      end

      def from(string_or_instant)
        case string_or_instant
        when Instant
          new(string_or_instant.epoch_nanoseconds)
        when String
          time = DateTime.iso8601(string_or_instant).to_time
          seconds_in_nanoseconds = time.tv_sec * 1000 * 1000 * 1000
          nanoseconds = time.tv_nsec
          new(seconds_in_nanoseconds + nanoseconds)
        else
          raise ArgumentError.new("This method requires an `Instant` or a `String`")
        end
      end

      def compare(instant_one, instant_two)
        instant_one <=> instant_two
      end
    end

    def initialize(epoch_nanoseconds)
      @epoch_nanoseconds = epoch_nanoseconds
    end

    def epoch_milliseconds
      (epoch_nanoseconds / 1000 / 1000).floor.to_i
    end

    def <=>(other)
      epoch_nanoseconds <=> other.epoch_nanoseconds
    end

    ROUNDING_UNITS = {
      nanosecond: 1,
      microsecond: 1_000,
      millisecond: 1_000_000,
      second: 1_000_000_000,
      minute: 60_000_000_000,
      hour: 3_600_000_000_000
    }

    ROUNDING_MODES = {
      ceil: [:ceil],
      floor: [:floor],
      expand: [:ceil],
      trunc: [:floor],
      half_ceil: [:round, half: "up"],
      half_floor: [:round, half: "down"],
      half_expand: [:round, half: "up"],
      half_trunc: [:round, half: "down"],
      half_even: [:round, half: "even"]
    }

    def round(positional_smallest_unit = nil, smallest_unit: nil, rounding_increment: 1, rounding_mode: :half_expand)
      smallest_unit ||= positional_smallest_unit

      unless ROUNDING_UNITS.has_key?(smallest_unit)
        keys = ROUNDING_UNITS.keys.join(", ")
        raise ArgumentError.new("Unsupported unit '#{smallest_unit}'. Smallest unit must be one of #{keys}")
      end

      unless ROUNDING_MODES.has_key?(rounding_mode)
        keys = ROUNDING_MODES.keys.join(", ")
        raise ArgumentError.new("Unsupported rounding mode '#{rounding_mode}'. Mode must be one of #{keys}")
      end

      divisor = rounding_increment * ROUNDING_UNITS[smallest_unit]
      round_method = ROUNDING_MODES[rounding_mode].first
      round_args = ROUNDING_MODES[rounding_mode][2]
      new_epoch = Rational(epoch_nanoseconds, divisor).public_send(round_method, **round_args).to_i * divisor
      Instant.new(new_epoch)
    end
  end
end
