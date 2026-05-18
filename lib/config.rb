require 'kostal_metrics'

Config = Data.define(
  :host,
  :protocol,
  :port,
  :interval,
  :metrics,
  :influx_schema,
  :influx_host,
  :influx_port,
  :influx_token,
  :influx_org,
  :influx_bucket,
  :influx_measurement,
  :logger,
) do
  def self.from_env
    new(
      host: ENV.fetch('KOSTAL_HOST', 'kostal'),
      protocol: ENV.fetch('KOSTAL_PROTOCOL', 'http'),
      port: ENV.fetch('KOSTAL_PORT', '80').to_i,
      interval: ENV.fetch('KOSTAL_INTERVAL', '10').to_i,
      metrics: KostalMetrics::DEFAULT_METRICS,
      influx_schema: ENV.fetch('INFLUX_SCHEMA', 'http'),
      influx_host: ENV.fetch('INFLUX_HOST', 'influxdb'),
      influx_port: ENV.fetch('INFLUX_PORT', '8086').to_i,
      influx_token: ENV.fetch('INFLUX_TOKEN', ''),
      influx_org: ENV.fetch('INFLUX_ORG', ''),
      influx_bucket: ENV.fetch('INFLUX_BUCKET', ''),
      influx_measurement: ENV.fetch('INFLUX_MEASUREMENT', 'KOSTAL'),
      logger: nil,
    )
  end

  def base_url
    "#{protocol}://#{host}:#{port}"
  end

  def influx_url
    "#{influx_schema}://#{influx_host}:#{influx_port}"
  end
end
