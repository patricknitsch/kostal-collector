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
  end
end
