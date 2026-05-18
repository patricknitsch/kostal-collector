require 'kostal_metrics'
require 'null_logger'
require 'uri'

KEYS = %i[
  host
  protocol
  port
  interval
  metrics
  influx_schema
  influx_host
  influx_port
  influx_token
  influx_org
  influx_bucket
  influx_measurement
].freeze

DEFAULTS = {
  host: 'kostal',
  protocol: 'http',
  port: 80,
  interval: 10,
  metrics: KostalMetrics::DEFAULT_METRICS,
  influx_schema: 'http',
  influx_host: 'influxdb',
  influx_port: 8086,
  influx_measurement: 'KOSTAL',
}.freeze

Config = Struct.new(*KEYS, keyword_init: true) do
  def initialize(**)
    super
    set_defaults
    set_types
    validate!
  end

  def self.from_env(**)
    env_options = {
      host: ENV.fetch('KOSTAL_HOST', nil),
      protocol: ENV.fetch('KOSTAL_PROTOCOL', nil),
      port: ENV.fetch('KOSTAL_PORT', nil),
      interval: ENV.fetch('KOSTAL_INTERVAL', nil),
      metrics: KostalMetrics::DEFAULT_METRICS,
      influx_schema: ENV.fetch('INFLUX_SCHEMA', nil),
      influx_host: ENV.fetch('INFLUX_HOST', nil),
      influx_port: ENV.fetch('INFLUX_PORT', nil),
      influx_token: ENV.fetch('INFLUX_TOKEN', nil),
      influx_org: ENV.fetch('INFLUX_ORG', nil),
      influx_bucket: ENV.fetch('INFLUX_BUCKET', nil),
      influx_measurement: ENV.fetch('INFLUX_MEASUREMENT', nil),
    }
    new(**env_options, **)
  end

  def base_url
    "#{protocol}://#{host}:#{port}"
  end

  def influx_url
    "#{influx_schema}://#{influx_host}:#{influx_port}"
  end

  attr_writer :logger

  def logger
    @logger ||= NullLogger.new
  end

  private

  def set_defaults
    DEFAULTS.each do |key, value|
      self[key] = value if self[key].nil?
    end
  end

  def set_types
    self[:port] = port.to_i
    self[:interval] = interval.to_i
    self[:influx_port] = influx_port.to_i
  end

  def validate!
    interval.positive? || raise(ArgumentError, "KOSTAL_INTERVAL is invalid: #{interval}")
    validate_url!(base_url)
    validate_influx_settings!
  end

  def validate_influx_settings!
    %i[
      influx_schema
      influx_host
      influx_port
      influx_org
      influx_bucket
      influx_token
      influx_measurement
    ].each do |key|
      key_name = key.to_s.upcase
      raise(ArgumentError, "#{key_name} is required") if self[key].to_s.empty?
    end

    validate_url!(influx_url)
  end

  def validate_url!(url)
    uri = URI.parse(url)
    raise(ArgumentError, "URL is invalid: #{url}") unless uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
  rescue URI::InvalidURIError
    raise ArgumentError, "URL is invalid: #{url}"
  end
end
