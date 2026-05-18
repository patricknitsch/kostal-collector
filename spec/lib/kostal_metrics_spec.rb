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
