module KostalMetrics
  DEFAULT_METRICS = [
    { name: 'ID_DCEingangsleistung', dxs_id: 33_556_736 },
    { name: 'ID_Ausgangsleistung', dxs_id: 67_109_120 },
    { name: 'ID_DC1Leistung', dxs_id: 33_555_203 },
    { name: 'ID_DC2Leistung', dxs_id: 33_555_459 },
    { name: 'ID_DC3Leistung', dxs_id: 33_555_715 },
    { name: 'ID_P1Leistung', dxs_id: 67_109_379 },
    { name: 'ID_P2Leistung', dxs_id: 67_109_635 },
    { name: 'ID_P3Leistung', dxs_id: 67_109_891 },
    { name: 'ID_Status', dxs_id: 16_780_032 },
  ].freeze

  module_function

  def to_lookup(metrics, entries)
    values_by_id = entries.each_with_object({}) do |entry, hash|
      hash[entry.fetch('dxsId').to_i] = entry['value']
    end

    metrics.each_with_object({}) do |metric, hash|
      hash[metric.fetch(:name)] = values_by_id[metric.fetch(:dxs_id)]
    end
  end
end
