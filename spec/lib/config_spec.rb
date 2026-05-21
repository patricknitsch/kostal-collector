require 'spec_helper'

describe Config do
  let(:base_options) do
    {
      host: 'example.com',
      protocol: 'http',
      port: 80,
      interval: 10,
      metrics: [],
      output: 'influxdb',
      influx_schema: 'http',
      influx_host: 'influxdb',
      influx_port: 8086,
      influx_token: 'token',
      influx_org: 'org',
      influx_bucket: 'bucket',
      influx_measurement: 'KOSTAL',
      mqtt_host: 'mqtt',
      mqtt_port: 1883,
      mqtt_topic_prefix: 'kostal',
    }
  end

  it 'requires influx settings only for influx output' do
    config = described_class.new(**base_options.merge(output: 'mqtt', influx_token: nil, influx_org: nil, influx_bucket: nil))
    expect(config.mqtt_output?).to be(true)
  end

  it 'requires mqtt settings only for mqtt output' do
    config = described_class.new(**base_options.merge(output: 'influxdb', mqtt_host: nil))
    expect(config.influx_output?).to be(true)
  end

  it 'validates output target values' do
    expect do
      described_class.new(**base_options.merge(output: 'stdout'))
    end.to raise_error(ArgumentError, /OUTPUT_TARGET is invalid/)
  end
end
