module KostalMetrics
  DEFAULT_METRICS = [
    { name: 'ID_DCEingangsleistung', dxs_id: 33_556_736, field: :dc_input_power, type: :float },
    { name: 'ID_Ausgangsleistung', dxs_id: 67_109_120, field: :output_power, type: :float },
    { name: 'ID_DC1Leistung', dxs_id: 33_555_203, field: :dc1_power, type: :float },
    { name: 'ID_DC2Leistung', dxs_id: 33_555_459, field: :dc2_power, type: :float },
    { name: 'ID_DC3Leistung', dxs_id: 33_555_715, field: :dc3_power, type: :float },
    { name: 'ID_P1Leistung', dxs_id: 67_109_379, field: :p1_power, type: :float },
    { name: 'ID_P2Leistung', dxs_id: 67_109_635, field: :p2_power, type: :float },
    { name: 'ID_P3Leistung', dxs_id: 67_109_891, field: :p3_power, type: :float },
    { name: 'ID_Status', dxs_id: 16_780_032, field: :status, type: :integer },
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

  def to_influx_fields(metrics, values_by_name)
    metrics.each_with_object({}) do |metric, hash|
      value = values_by_name[metric.fetch(:name)]
      next if value.nil?

      hash[metric.fetch(:field)] = cast(value, metric.fetch(:type))
    end
  end

  def cast(value, type)
    case type
    when :integer
      value.to_i
    when :float
      value.to_f
    when :string
      value.to_s
    when :boolean
      value == true || value.to_s == 'true'
    else
      value
    end
  end
end
