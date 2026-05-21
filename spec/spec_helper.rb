$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'rspec'
require 'config'

def build_config(**overrides)
  logger = overrides.delete(:logger)
  defaults = {
    host: 'example.com',
    protocol: 'http',
    port: 80,
    interval: 10,
    metrics: [
      { name: 'ID_Ausgangsleistung', dxs_id: 67_109_120, field: :ac_output_power, type: :float },
      { name: 'ID_Status', dxs_id: 16_780_032, field: :status, type: :integer },
    ],
    output: 'influxdb',
    influx_schema: 'http',
    influx_host: 'influxdb',
    influx_port: 8086,
    influx_token: 'token',
    influx_org: 'org',
    influx_bucket: 'bucket',
    influx_measurement: 'KOSTAL',
  }

  config = Config.new(**defaults.merge(overrides))
  config.logger = logger if logger
  config
end
