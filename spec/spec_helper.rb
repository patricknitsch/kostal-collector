$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'rspec'
require 'config'

def build_config(**overrides)
  defaults = {
    host: 'example.com',
    protocol: 'http',
    port: 80,
    interval: 10,
    metrics: KostalMetrics::DEFAULT_METRICS,
    influx_schema: 'http',
    influx_host: 'influxdb',
    influx_port: 8086,
    influx_token: 'token',
    influx_org: 'org',
    influx_bucket: 'bucket',
    influx_measurement: 'KOSTAL',
    logger: nil,
  }

  Config.new(**defaults.merge(overrides))
end
