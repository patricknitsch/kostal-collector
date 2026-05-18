require 'spec_helper'
require 'influx_push'
require 'kostal_record'

describe InfluxPush do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) { build_config(logger:) }
  let(:flux_writer) { instance_double(FluxWriter, ready?: true, push: nil) }
  let(:queue) { instance_double(Queue) }

  subject(:influx_push) { described_class.new(config:, queue:, flux_writer:, retry_sleep: 0) }

  describe '#run' do
    it 'pushes queued records to InfluxDB' do
      record = KostalRecord.new(1, measure_time: 1_700_000_000, output_power: 1234.0)
      allow(queue).to receive(:closed?).and_return(false, true)
      allow(queue).to receive(:pop).and_return(record)

      influx_push.run

      expect(flux_writer).to have_received(:push).with(record)
    end

    it 'requeues records when write fails' do
      record = KostalRecord.new(1, measure_time: 1_700_000_000, output_power: 1234.0)
      allow(queue).to receive(:closed?).and_return(false, false, true)
      allow(queue).to receive(:pop).and_return(record)
      allow(queue).to receive(:<<)
      allow(queue).to receive(:size).and_return(1)
      allow(flux_writer).to receive(:push).and_raise(StandardError, 'boom')

      influx_push.run

      expect(queue).to have_received(:<<).with(record)
      expect(logger).to have_received(:error).with(/boom/)
    end
  end
end
