module KostalMetrics
  DEFAULT_METRICS = [
    { name: 'ID_DCEingangsleistung', dxs_id: 33_556_736, field: :dc_input_power, type: :float },
    { name: 'ID_Ausgangsleistung', dxs_id: 67_109_120, field: :ac_output_power, type: :float },
    { name: 'ID_DC1Leistung', dxs_id: 33_555_203, field: :dc_1_power, type: :float },
    { name: 'ID_DC2Leistung', dxs_id: 33_555_459, field: :dc_2_power, type: :float },
    { name: 'ID_DC3Leistung', dxs_id: 33_555_715, field: :dc_3_power, type: :float },
    { name: 'ID_P1Leistung', dxs_id: 67_109_379, field: :ac_1_power, type: :float },
    { name: 'ID_P2Leistung', dxs_id: 67_109_635, field: :ac_2_power, type: :float },
    { name: 'ID_P3Leistung', dxs_id: 67_109_891, field: :ac_3_power, type: :float },
    { name: 'ID_Status', dxs_id: 16_780_032, field: :status, type: :integer },
  ].freeze

  VALID_TYPES = %i[float integer string boolean].freeze

  TYPE_ALIASES = { 'int' => :integer, 'bool' => :boolean }.freeze

  module_function

  def from_env
    raw = ENV.fetch('KOSTAL_METRICS', nil)
    return DEFAULT_METRICS if raw.nil? || raw.strip.empty?

    raw.strip.split(/[\s,]+/).filter_map do |entry|
      entry = entry.strip
      next if entry.empty?

      parts = entry.split(':')
      unless parts.length == 3
        raise ArgumentError, "Invalid KOSTAL_METRICS entry: #{entry.inspect} (expected dxs_id:field:type)"
      end

      dxs_id_str, field_str, type_str = parts
      dxs_id = Integer(dxs_id_str)
      type = TYPE_ALIASES.fetch(type_str, type_str.to_sym)
      unless VALID_TYPES.include?(type)
        raise ArgumentError, "Unknown type #{type_str.inspect} in KOSTAL_METRICS (valid: #{VALID_TYPES.join(', ')})"
      end

      { name: field_str, dxs_id:, field: field_str.to_sym, type: }
    end
  end

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
