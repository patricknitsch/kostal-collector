module KostalMetrics
  SUPPORTED_METRICS = [
    # Leistungswerte
    { name: 'ID_DCEingangGesamt',        dxs_id: 33_556_736,  field: :ID_DCEingangGesamt,        type: :float },
    { name: 'ID_Ausgangsleistung',       dxs_id: 67_109_120,  field: :ID_Ausgangsleistung,       type: :float },
    { name: 'ID_Eigenverbrauch',         dxs_id: 83_888_128,  field: :ID_Eigenverbrauch,         type: :float },
    # Status
    { name: 'ID_Status',                 dxs_id: 16_780_032,  field: :ID_Status,                 type: :integer },
    # Statistik - Tag
    { name: 'ID_Ertrag_d',               dxs_id: 251_658_754, field: :ID_Ertrag_d,               type: :float },
    { name: 'ID_Hausverbrauch_d',        dxs_id: 251_659_010, field: :ID_Hausverbrauch_d,        type: :float },
    { name: 'ID_Eigenverbrauch_d',       dxs_id: 251_659_266, field: :ID_Eigenverbrauch_d,       type: :float },
    { name: 'ID_Eigenverbrauchsquote_d', dxs_id: 251_659_278, field: :ID_Eigenverbrauchsquote_d, type: :float },
    { name: 'ID_Autarkiegrad_d',         dxs_id: 251_659_279, field: :ID_Autarkiegrad_d,         type: :float },
    # Statistik - Gesamt
    { name: 'ID_Ertrag_G',               dxs_id: 251_658_753, field: :ID_Ertrag_G,               type: :float },
    { name: 'ID_Hausverbrauch_G',        dxs_id: 251_659_009, field: :ID_Hausverbrauch_G,        type: :float },
    { name: 'ID_Eigenverbrauch_G',       dxs_id: 251_659_265, field: :ID_Eigenverbrauch_G,       type: :float },
    { name: 'ID_Eigenverbrauchsquote_G', dxs_id: 251_659_280, field: :ID_Eigenverbrauchsquote_G, type: :float },
    { name: 'ID_Autarkiegrad_G',         dxs_id: 251_659_281, field: :ID_Autarkiegrad_G,         type: :float },
    { name: 'ID_Betriebszeit',           dxs_id: 251_658_496, field: :ID_Betriebszeit,           type: :float },
    # Momentanwerte - PV Generator
    { name: 'ID_DC1Spannung',            dxs_id: 33_555_202,  field: :ID_DC1Spannung,            type: :float },
    { name: 'ID_DC1Strom',               dxs_id: 33_555_201,  field: :ID_DC1Strom,               type: :float },
    { name: 'ID_DC1Leistung',            dxs_id: 33_555_203,  field: :ID_DC1Leistung,            type: :float },
    { name: 'ID_DC2Spannung',            dxs_id: 33_555_458,  field: :ID_DC2Spannung,            type: :float },
    { name: 'ID_DC2Strom',               dxs_id: 33_555_457,  field: :ID_DC2Strom,               type: :float },
    { name: 'ID_DC2Leistung',            dxs_id: 33_555_459,  field: :ID_DC2Leistung,            type: :float },
    # Momentanwerte Haus
    { name: 'ID_HausverbrauchSolar',     dxs_id: 83_886_336,  field: :ID_HausverbrauchSolar,     type: :float },
    { name: 'ID_HausverbrauchBatterie',  dxs_id: 83_886_592,  field: :ID_HausverbrauchBatterie,  type: :float },
    { name: 'ID_HausverbrauchNetz',      dxs_id: 83_886_848,  field: :ID_HausverbrauchNetz,      type: :float },
    { name: 'ID_HausverbrauchPhase1',    dxs_id: 83_887_106,  field: :ID_HausverbrauchPhase1,    type: :float },
    { name: 'ID_HausverbrauchPhase2',    dxs_id: 83_887_362,  field: :ID_HausverbrauchPhase2,    type: :float },
    { name: 'ID_HausverbrauchPhase3',    dxs_id: 83_887_618,  field: :ID_HausverbrauchPhase3,    type: :float },
    # Netz
    { name: 'ID_NetzFrequenz',           dxs_id: 67_110_400,  field: :ID_NetzFrequenz,           type: :float },
    { name: 'ID_NetzCosPhi',             dxs_id: 67_110_656,  field: :ID_NetzCosPhi,             type: :float },
    # Netz Phase 1
    { name: 'ID_P1Spannung',             dxs_id: 67_109_378,  field: :ID_P1Spannung,             type: :float },
    { name: 'ID_P1Strom',                dxs_id: 67_109_377,  field: :ID_P1Strom,                type: :float },
    { name: 'ID_P1Leistung',             dxs_id: 67_109_379,  field: :ID_P1Leistung,             type: :float },
    # Netz Phase 2
    { name: 'ID_P2Spannung',             dxs_id: 67_109_634,  field: :ID_P2Spannung,             type: :float },
    { name: 'ID_P2Strom',                dxs_id: 67_109_633,  field: :ID_P2Strom,                type: :float },
    { name: 'ID_P2Leistung',             dxs_id: 67_109_635,  field: :ID_P2Leistung,             type: :float },
    # Netz Phase 3
    { name: 'ID_P3Spannung',             dxs_id: 67_109_890,  field: :ID_P3Spannung,             type: :float },
    { name: 'ID_P3Strom',                dxs_id: 67_109_889,  field: :ID_P3Strom,                type: :float },
    { name: 'ID_P3Leistung',             dxs_id: 67_109_891,  field: :ID_P3Leistung,             type: :float },
  ].freeze

  EMPTY_METRICS = [].freeze

  VALID_TYPES = %i[float integer string boolean].freeze

  TYPE_ALIASES = { 'int' => :integer, 'bool' => :boolean }.freeze

  module_function

  def from_env
    raw = ENV.fetch('KOSTAL_METRICS', nil)
    return EMPTY_METRICS if raw.nil? || raw.strip.empty?

    parse_metrics(raw)
  end

  def parse_metrics(raw)
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
