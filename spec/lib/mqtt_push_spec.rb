require 'spec_helper'
require 'mqtt_push'
require 'kostal_record'

describe MqttPush do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) do
    build_config(
      logger:,
      output: 'mqtt',
      mqtt_host: 'mqtt',
      mqtt_port: 1883,
      mqtt_topic_prefix: 'kostal',
      mqtt_retain: false,
    )
  end
  let(:queue) { instance_double(Queue) }

  subject(:mqtt_push) { described_class.new(config:, queue:, retry_sleep: 0) }

  describe '#run' do
    it 'publishes record fields to mqtt topics' do
      record = KostalRecord.new(1, measure_time: 1_700_000_000, ac_output_power: 1234.0, status: 2)
      client = instance_double(MQTT::Client, publish: true)

      allow(queue).to receive(:closed?).and_return(false, true)
      allow(queue).to receive(:pop).and_return(record)
      allow(MQTT::Client).to receive(:connect).and_yield(client)

      mqtt_push.run

      expect(client).to have_received(:publish).with('kostal/measure_time', '1700000000', false)
      expect(client).to have_received(:publish).with('kostal/ac_output_power', '1234.0', false)
      expect(client).to have_received(:publish).with('kostal/status', '2', false)
    end
  end
end
