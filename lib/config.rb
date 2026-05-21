require 'kostal_metrics'
require 'null_logger'
require 'uri'

KEYS = %i[
  host
  protocol
  port
  interval
  metrics
  output
  influx_schema
  influx_host
  influx_port
  influx_token
  influx_org
  influx_bucket
  influx_measurement
  mqtt_host
  mqtt_port
  mqtt_username
  mqtt_password
  mqtt_topic_prefix
  mqtt_retain
].freeze

DEFAULTS = {
  host: 'kostal',
  protocol: 'http',
  port: 80,
  interval: 10,
  output: 'influxdb',
  influx_schema: 'http',
  influx_host: 'influxdb',
  influx_port: 8086,
  mqtt_port: 1883,
  mqtt_topic_prefix: 'kostal',
  mqtt_retain: false,
}.freeze

Config = Struct.new(*KEYS, keyword_init: true) do
  def initialize(**)
    super
    set_defaults
    set_types
    validate!
  end

  def self.from_env(**)
    output = ENV.fetch('OUTPUT_TARGET', 'influxdb')
    consumption = ENV.fetch('KOSTAL_CONSUMPTION', 'true') != 'false'

    metrics = if output == 'mqtt'
      base = KostalMetrics::SUPPORTED_METRICS
      consumption ? base : KostalMetrics.without_consumption(base)
    else
      KostalMetrics.from_env
    end

    env_options = {
      host: ENV.fetch('KOSTAL_HOST', nil),
      protocol: ENV.fetch('KOSTAL_PROTOCOL', nil),
      port: ENV.fetch('KOSTAL_PORT', nil),
      interval: ENV.fetch('KOSTAL_INTERVAL', nil),
      metrics:,
      output:,
      influx_schema: ENV.fetch('INFLUX_SCHEMA', nil),
      influx_host: ENV.fetch('INFLUX_HOST', nil),
      influx_port: ENV.fetch('INFLUX_PORT', nil),
      influx_token: ENV.fetch('INFLUX_TOKEN', nil),
      influx_org: ENV.fetch('INFLUX_ORG', nil),
      influx_bucket: ENV.fetch('INFLUX_BUCKET', nil),
      influx_measurement: ENV.fetch('INFLUX_MEASUREMENT_KOSTAL', nil),
      mqtt_host: ENV.fetch('MQTT_HOST', nil),
      mqtt_port: ENV.fetch('MQTT_PORT', nil),
      mqtt_username: ENV.fetch('MQTT_USERNAME', nil),
      mqtt_password: ENV.fetch('MQTT_PASSWORD', nil),
      mqtt_topic_prefix: ENV.fetch('MQTT_TOPIC_PREFIX', nil),
      mqtt_retain: ENV.fetch('MQTT_RETAIN', nil),
    }
    new(**env_options, **)
  end

  def base_url
    "#{protocol}://#{host}:#{port}"
  end

  def influx_url
    "#{influx_schema}://#{influx_host}:#{influx_port}"
  end

  def influx_output?
    output == 'influxdb'
  end

  def mqtt_output?
    output == 'mqtt'
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
    self[:mqtt_port] = mqtt_port.to_i
    self[:mqtt_retain] = mqtt_retain == true || mqtt_retain.to_s == 'true'
  end

  def validate!
    interval.positive? || raise(ArgumentError, "KOSTAL_INTERVAL is invalid: #{interval}")
    validate_url!(base_url)
    validate_output!
    validate_influx_settings! if influx_output?
    validate_mqtt_settings! if mqtt_output?
  end

  def validate_output!
    return if %w[influxdb mqtt].include?(output)

    raise(ArgumentError, "OUTPUT_TARGET is invalid: #{output.inspect} (allowed: influxdb, mqtt)")
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

    raise(ArgumentError, 'INFLUX_PORT must be greater than 0') unless influx_port.positive?

    validate_url!(influx_url)
  end

  def validate_mqtt_settings!
    %i[
      mqtt_host
      mqtt_port
      mqtt_topic_prefix
    ].each do |key|
      key_name = key.to_s.upcase
      raise(ArgumentError, "#{key_name} is required") if self[key].to_s.empty?
    end

    raise(ArgumentError, 'MQTT_PORT must be greater than 0') unless mqtt_port.positive?
  end

  def validate_url!(url)
    uri = URI.parse(url)
    raise(ArgumentError, "URL is invalid: #{url}") unless uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
  rescue URI::InvalidURIError
    raise ArgumentError, "URL is invalid: #{url}"
  end
end
