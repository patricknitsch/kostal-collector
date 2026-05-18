require 'spec_helper'
require 'loop'

describe Loop do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) { build_config(interval: 1, logger:) }
  let(:record) { instance_double(KostalRecord) }
  let(:kostal_pull) { instance_double(KostalPull, next: record, count: 1) }
  let(:influx_push) { instance_double(InfluxPush, ready?: true, run: true) }
  let(:loop_instance) { described_class.new(config:, max_count: 1, max_wait: 0) }

  before do
    allow(loop_instance).to receive(:kostal_pull).and_return(kostal_pull)
    allow(loop_instance).to receive(:influx_push).and_return(influx_push)
  end

  describe '#start' do
    it 'returns when InfluxDB is not ready' do
      allow(influx_push).to receive(:ready?).and_return(false)
      allow(loop_instance).to receive(:sleep)

      loop_instance.start

      expect(kostal_pull).not_to have_received(:next)
    end

    it 'runs pull and push loops when InfluxDB is ready' do
      loop_instance.start

      expect(kostal_pull).to have_received(:next).once
      expect(influx_push).to have_received(:run).once
      expect(loop_instance.queue.closed?).to be(true)
    end
  end
end
