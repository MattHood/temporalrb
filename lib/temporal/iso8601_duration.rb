module Temporal
  class ISO8601Duration
    def initialize(duration_string)
      @duration_string = duration_string
    end

    SIGN = /(?<sign>\+|-)?/
    PERIOD = /[pP]/
    YEARS = /(?:(?<years>\d+)Y|)/
    MONTHS = /(?:(?<months>\d+)M|)/
    WEEKS = /(?:(?<weeks>\d+)W|)/
    DAYS = /(?:(?<days>\d+)D|)/

    HOURS = /(?:(?<hours>\d+)H|)/
    MINUTES = /(?:(?<minutes>\d+)M|)/
    MILLISECONDS = /(?<milliseconds>\d{1,3})/
    MICROSECONDS = /(?<microseconds>\d{0,3})/
    NANOSECONDS = /(?<nanoseconds>\d{0,3})/
    SECONDS = /(?:(?<seconds>\d+)(?:\.#{MILLISECONDS}#{MICROSECONDS}#{NANOSECONDS})?S|)/
    TIME = /(?:T(?=.)#{HOURS}#{MINUTES}#{SECONDS}|)/

    ISO8601_DURATION = /^#{SIGN}#{PERIOD}#{YEARS}#{MONTHS}#{WEEKS}#{DAYS}#{TIME}$/

    def to_h
      match = ISO8601_DURATION.match(@duration_string)
      if match.nil?
        raise RangeError.new("Invalid duration: #{@duration_string}")
      else
        captures = match.named_captures.reject { |k, v| k == "sign" || v.nil? || v == "" }
        sign = (match["sign"] == "-") ? -1 : 1

        unless captures.count > 0
          raise RangeError.new("Invalid duration: #{@duration_string}")
        end

        captures.map do |key, value|
          if %w[years months weeks days hours minutes seconds].include?(key)
            [key.to_sym, sign * value.to_i]
          elsif %w[milliseconds microseconds nanoseconds].include?(key)
            [key.to_sym, sign * value.ljust(3, "0").to_i]
          else
            raise "Internal error: unrecognised named capture."
          end
        end.to_h
      end
    end
  end
end
