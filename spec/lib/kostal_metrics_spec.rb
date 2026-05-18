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
      it 'returns DEFAULT_METRICS' do
        expect(described_class.from_env).to eq(described_class::DEFAULT_METRICS)
      end
    end

    context 'with KOSTAL_METRICS overriding one default entry' do
      around do |example|
        ENV['KOSTAL_METRICS'] = '33556736:my_power:float'
        example.run
        ENV.delete('KOSTAL_METRICS')
      end

      it 'merges override with remaining defaults' do
        metrics = described_class.from_env
        expect(metrics.length).to eq(described_class::DEFAULT_METRICS.length)
        overridden = metrics.find { |m| m[:dxs_id] == 33_556_736 }
        expect(overridden).to eq(name: 'my_power', dxs_id: 33_556_736, field: :my_power, type: :float)
        expect(metrics.map { |m| m[:dxs_id] }).to include(67_109_120, 16_780_032)
      end
    end

    context 'with KOSTAL_METRICS adding a new dxs_id' do
      around do |example|
        ENV['KOSTAL_METRICS'] = '99999999:extra_field:integer'
        example.run
        ENV.delete('KOSTAL_METRICS')
      end

      it 'appends the new entry after defaults' do
        metrics = described_class.from_env
        expect(metrics.length).to eq(described_class::DEFAULT_METRICS.length + 1)
        expect(metrics.last).to eq(name: 'extra_field', dxs_id: 99_999_999, field: :extra_field, type: :integer)
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

  describe 'DEFAULT_METRICS' do
    it 'contains all required IDs' do
      names = described_class::DEFAULT_METRICS.map { |metric| metric[:name] }

      expect(names).to include(
        'ID_DCEingangsleistung',
        'ID_Ausgangsleistung',
        'ID_DC1Leistung',
        'ID_DC2Leistung',
        'ID_DC3Leistung',
        'ID_P1Leistung',
        'ID_P2Leistung',
        'ID_P3Leistung',
        'ID_Status',
      )
    end

    it 'defines field and type for all metrics' do
      described_class::DEFAULT_METRICS.each do |metric|
        expect(metric).to include(:field, :type)
      end
    end
  end
end
