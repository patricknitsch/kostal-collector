require 'spec_helper'
require 'influx_push'

describe InfluxPush do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) { build_config(logger:) }
  let(:flux_writer) { instance_double(FluxWriter, ready?: true, push: nil) }

  subject(:influx_push) { described_class.new(config:, flux_writer:) }

  describe '#push' do
    it 'casts fields by configured type and pushes to InfluxDB' do
      allow(Time).to receive(:now).and_return(Time.at(1_700_000_000))

      expect(flux_writer).to receive(:push).with(
        fields: hash_including(output_power: 1234.0, status: 2),
        measure_time: 1_700_000_000,
      )

      influx_push.push(
        'ID_Ausgangsleistung' => '1234',
        'ID_Status' => '2',
      )
    end
  end
end
