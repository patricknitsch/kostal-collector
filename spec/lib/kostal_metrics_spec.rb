require 'spec_helper'
require 'kostal_metrics'

describe KostalMetrics do
  describe '.to_lookup' do
    it 'maps configured metric names to entry values by dxsId' do
      metrics = [
        { name: 'ID_A', dxs_id: 11 },
        { name: 'ID_B', dxs_id: 22 },
      ]
      entries = [
        { 'dxsId' => 22, 'value' => 200 },
        { 'dxsId' => 11, 'value' => 100 },
      ]

      expect(described_class.to_lookup(metrics, entries)).to eq(
        'ID_A' => 100,
        'ID_B' => 200,
      )
    end
  end

  describe '.to_influx_fields' do
    it 'maps names to configured field names and casts field types' do
      metrics = [
        { name: 'ID_POWER', dxs_id: 11, field: :power, type: :float },
        { name: 'ID_STATUS', dxs_id: 12, field: :status, type: :integer },
      ]

      values = {
        'ID_POWER' => '1234.5',
        'ID_STATUS' => '2',
      }

      expect(described_class.to_influx_fields(metrics, values)).to eq(
        power: 1234.5,
        status: 2,
      )
    end
  end

  describe '.from_env' do
    context 'without KOSTAL_METRICS set' do
      it 'returns an empty list' do
        expect(described_class.from_env).to eq(described_class::EMPTY_METRICS)
      end
    end

    context 'with KOSTAL_METRICS set' do
      around do |example|
        ENV['KOSTAL_METRICS'] = '33556736:my_power:float 16780032:my_status:integer'
        example.run
        ENV.delete('KOSTAL_METRICS')
      end

      it 'uses exactly configured metrics' do
        metrics = described_class.from_env
        expect(metrics).to eq(
          [
            { name: 'my_power', dxs_id: 33_556_736, field: :my_power, type: :float },
            { name: 'my_status', dxs_id: 16_780_032, field: :my_status, type: :integer },
          ],
        )
      end
    end

    context 'with an invalid entry' do
      around do |example|
        ENV['KOSTAL_METRICS'] = '33556736:dc_input_power'
        example.run
        ENV.delete('KOSTAL_METRICS')
      end

      it 'raises ArgumentError' do
        expect { described_class.from_env }.to raise_error(ArgumentError, /Invalid KOSTAL_METRICS entry/)
      end
    end

    context 'with an unknown type' do
      around do |example|
        ENV['KOSTAL_METRICS'] = '33556736:dc_input_power:number'
        example.run
        ENV.delete('KOSTAL_METRICS')
      end

      it 'raises ArgumentError' do
        expect { described_class.from_env }.to raise_error(ArgumentError, /Unknown type/)
      end
    end
  end

  describe 'SUPPORTED_METRICS' do
    it 'contains configured IDs from the extended adapter list' do
      ids = described_class::SUPPORTED_METRICS.map { |metric| metric[:dxs_id] }
      expect(ids).to include(
        33_556_736,
        67_109_120,
        83_888_128,
        16_780_032,
        251_658_754,
        251_659_010,
        251_659_266,
        251_659_278,
        251_659_279,
        251_658_753,
        251_659_009,
        251_659_265,
        251_659_280,
        251_659_281,
        251_658_496,
        67_110_400,
        67_110_656,
      )
    end

    it 'defines a type for all supported metrics' do
      described_class::SUPPORTED_METRICS.each do |metric|
        expect(metric).to include(:type)
      end
    end
  end
end
