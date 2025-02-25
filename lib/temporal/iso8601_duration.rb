module Temporal
  class ISO8601Duration
    FIELDS = %i[sign years months weeks days hours minutes seconds milliseconds microseconds nanoseconds]
    attr_accessor(*FIELDS)

    def initialize(arg = nil)
      case arg
      when nil
        initialize_to_zero
      when String
        initialize_from_string(arg)
      when Hash
        initialize_from_hash(arg)
      else
        raise ArgumentError.new("Must be a a string or a hash")
      end
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
      {sign:, years:, months:, weeks:, days:, hours:, minutes:, seconds:, milliseconds:, microseconds:, nanoseconds:}
    end

    def to_s
      sign_s = (sign == -1) ? "-" : ""
      years_s = years.nonzero? ? "#{years}Y" : ""
      months_s = months.nonzero? ? "#{months}M" : ""
      weeks_s = weeks.nonzero? ? "#{weeks}W" : ""
      days_s = days.nonzero? ? "#{days}D" : ""
      date_s = sign_s + "P" + years_s + months_s + weeks_s + days_s

      time_values = [hours, minutes, seconds, milliseconds, microseconds, nanoseconds]
      time_s = if time_values.any?(&:nonzero?)
        hours_s = hours.nonzero? ? "#{hours}H" : ""
        minutes_s = minutes.nonzero? ? "#{minutes}M" : ""

        subsecond_values = [milliseconds, microseconds, nanoseconds]
        seconds_s = if subsecond_values.any?(&:nonzero?)
          seconds_bal, nanoseconds_bal = Vector[seconds, milliseconds, microseconds, nanoseconds]
            .inner_product(Vector[10**9, 10**6, 10**3, 1])
            .divmod(10**9)
          seconds_bal.to_s + "." + nanoseconds_bal.to_s.gsub(/0+$/, "") + "S"
        else
          seconds.nonzero? ? "#{seconds}S" : ""
        end

        "T" + hours_s + minutes_s + seconds_s
      else
        ""
      end

      date_s + time_s
    end

    private

    def initialize_from_string(duration_string)
      match = ISO8601_DURATION.match(duration_string)
      if match.nil?
        raise RangeError.new("Invalid duration: #{@duration_string}")
      else
        captures = match.named_captures.reject { |k, v| v.nil? || v == "" }
        self.sign = (captures.delete("sign") == "-") ? -1 : 1

        unless captures.count > 0
          raise RangeError.new("Invalid duration: #{@duration_string}")
        end

        captures.each do |key, value|
          parsed_value = if %w[years months weeks days hours minutes seconds].include?(key)
            value.to_i
          elsif %w[milliseconds microseconds nanoseconds].include?(key)
            value.ljust(3, "0").to_i
          else
            raise "Internal error: unrecognised named capture."
          end

          public_send :"#{key}=", parsed_value
        end
      end
    end

    def initialize_to_zero
      FIELDS.each { |field| public_send(:"#{field}=", 0) }
      self.sign = 1
    end

    def initialize_from_hash(arg)
      unless (arg.keys - FIELDS).empty?
        raise ArgumentError.new("Unrecognised attributes: #{(arg.keys - FIELDS).join(", ")}")
      end

      FIELDS.each do |field|
        value = if field == :sign
          arg[field] || 1
        else
          arg[field] || 0
        end
        public_send(:"#{field}=", value)
      end
    end
  end
end
