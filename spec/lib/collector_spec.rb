require 'spec_helper'
require 'collector'

describe Collector do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) { build_config(interval: 0, logger:) }
  let(:client) { instance_double(KostalClient, fetch: { 'ID_Status' => 1 }) }
  let(:influx_push) { instance_double(InfluxPush, ready?: true, push: nil) }

  describe '#run' do
    it 'collects and pushes values when InfluxDB is ready' do
      collector = described_class.new(config:, client:, influx_push:)
      collector.run(max_count: 1)

      expect(client).to have_received(:fetch).once
      expect(influx_push).to have_received(:push).with('ID_Status' => 1)
    end

    it 'does not collect values when InfluxDB is not ready' do
      allow(influx_push).to receive(:ready?).and_return(false)

      collector = described_class.new(config:, client:, influx_push:)
      collector.run(max_count: 1)

      expect(client).not_to have_received(:fetch)
    end
  end
end
