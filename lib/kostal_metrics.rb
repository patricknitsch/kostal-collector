module KostalMetrics
  SUPPORTED_METRICS = [
    # Leistungswerte
    { name: 'DCEingangGesamt',        dxs_id: 33_556_736,   field: :DCEingangGesamt,        type: :float },
    { name: 'Ausgangsleistung',       dxs_id: 67_109_120,   field: :Ausgangsleistung,       type: :float },
    { name: 'Eigenverbrauch',         dxs_id: 83_888_128,   field: :Eigenverbrauch,         type: :float },
    { name: 'Hausverbrauch',          dxs_id: 83_887_872,   field: :Hausverbrauch,          type: :float },
    # Status
    { name: 'Status',                 dxs_id: 16_780_032,   field: :Status,                 type: :integer },
    # Wechselrichterinfo
    { name: 'WRName',                 dxs_id: 16_777_984,   field: :WRName,                 type: :string },
    { name: 'WRArtikel',              dxs_id: 16_779_267,   field: :WRArtikel,              type: :string },
    { name: 'WRSeriennummer',         dxs_id: 16_780_544,   field: :WRSeriennummer,         type: :string },
    # Statistik - Tag
    { name: 'Ertrag_d',               dxs_id: 251_658_754,  field: :Ertrag_d,               type: :float },
    { name: 'Hausverbrauch_d',        dxs_id: 251_659_010,  field: :Hausverbrauch_d,        type: :float },
    { name: 'Eigenverbrauch_d',       dxs_id: 251_659_266,  field: :Eigenverbrauch_d,       type: :float },
    { name: 'Eigenverbrauchsquote_d', dxs_id: 251_659_278,  field: :Eigenverbrauchsquote_d, type: :float },
    { name: 'Autarkiegrad_d',         dxs_id: 251_659_279,  field: :Autarkiegrad_d,         type: :float },
    # Statistik - Gesamt
    { name: 'Ertrag_G',               dxs_id: 251_658_753,  field: :Ertrag_G,               type: :float },
    { name: 'Hausverbrauch_G',        dxs_id: 251_659_009,  field: :Hausverbrauch_G,        type: :float },
    { name: 'Eigenverbrauch_G',       dxs_id: 251_659_265,  field: :Eigenverbrauch_G,       type: :float },
    { name: 'Eigenverbrauchsquote_G', dxs_id: 251_659_280,  field: :Eigenverbrauchsquote_G, type: :float },
    { name: 'Autarkiegrad_G',         dxs_id: 251_659_281,  field: :Autarkiegrad_G,         type: :float },
    { name: 'Betriebszeit',           dxs_id: 251_658_496,  field: :Betriebszeit,           type: :float },
    # PV Generator DC String 1
    { name: 'DC1Spannung',            dxs_id: 33_555_202,   field: :DC1Spannung,            type: :float },
    { name: 'DC1Strom',               dxs_id: 33_555_201,   field: :DC1Strom,               type: :float },
    { name: 'DC1Leistung',            dxs_id: 33_555_203,   field: :DC1Leistung,            type: :float },
    # PV Generator DC String 2
    { name: 'DC2Spannung',            dxs_id: 33_555_458,   field: :DC2Spannung,            type: :float },
    { name: 'DC2Strom',               dxs_id: 33_555_457,   field: :DC2Strom,               type: :float },
    { name: 'DC2Leistung',            dxs_id: 33_555_459,   field: :DC2Leistung,            type: :float },
    # PV Generator DC String 3
    { name: 'DC3Spannung',            dxs_id: 33_555_714,   field: :DC3Spannung,            type: :float },
    { name: 'DC3Strom',               dxs_id: 33_555_713,   field: :DC3Strom,               type: :float },
    { name: 'DC3Leistung',            dxs_id: 33_555_715,   field: :DC3Leistung,            type: :float },
    # Batterie
    { name: 'BatterieSOC',            dxs_id: 33_556_226,   field: :BatterieSOC,            type: :float },
    { name: 'BatterieStatus',         dxs_id: 33_556_227,   field: :BatterieStatus,         type: :integer },
    { name: 'BatterieStrom',          dxs_id: 33_556_228,   field: :BatterieStrom,          type: :float },
    { name: 'BatterieSpannung',       dxs_id: 33_556_229,   field: :BatterieSpannung,       type: :float },
    { name: 'BatterieLeistung',       dxs_id: 33_556_230,   field: :BatterieLeistung,       type: :float },
    { name: 'BatterieTemp',           dxs_id: 33_556_238,   field: :BatterieTemp,           type: :float },
    # Hausverbrauch nach Quelle
    { name: 'HausverbrauchSolar',     dxs_id: 83_886_336,   field: :HausverbrauchSolar,     type: :float },
    { name: 'HausverbrauchBatterie',  dxs_id: 83_886_592,   field: :HausverbrauchBatterie,  type: :float },
    { name: 'HausverbrauchNetz',      dxs_id: 83_886_848,   field: :HausverbrauchNetz,      type: :float },
    { name: 'HausverbrauchPhase1',    dxs_id: 83_887_106,   field: :HausverbrauchPhase1,    type: :float },
    { name: 'HausverbrauchPhase2',    dxs_id: 83_887_362,   field: :HausverbrauchPhase2,    type: :float },
    { name: 'HausverbrauchPhase3',    dxs_id: 83_887_618,   field: :HausverbrauchPhase3,    type: :float },
    # Netz
    { name: 'NetzFrequenz',           dxs_id: 67_110_400,   field: :NetzFrequenz,           type: :float },
    { name: 'NetzCosPhi',             dxs_id: 67_110_656,   field: :NetzCosPhi,             type: :float },
    { name: 'NetzEinspeiselimit',     dxs_id: 67_110_144,   field: :NetzEinspeiselimit,     type: :float },
    # Netz Phase 1
    { name: 'P1Spannung',             dxs_id: 67_109_378,   field: :P1Spannung,             type: :float },
    { name: 'P1Strom',                dxs_id: 67_109_377,   field: :P1Strom,                type: :float },
    { name: 'P1Leistung',             dxs_id: 67_109_379,   field: :P1Leistung,             type: :float },
    # Netz Phase 2
    { name: 'P2Spannung',             dxs_id: 67_109_634,   field: :P2Spannung,             type: :float },
    { name: 'P2Strom',                dxs_id: 67_109_633,   field: :P2Strom,                type: :float },
    { name: 'P2Leistung',             dxs_id: 67_109_635,   field: :P2Leistung,             type: :float },
    # Netz Phase 3
    { name: 'P3Spannung',             dxs_id: 67_109_890,   field: :P3Spannung,             type: :float },
    { name: 'P3Strom',                dxs_id: 67_109_889,   field: :P3Strom,                type: :float },
    { name: 'P3Leistung',             dxs_id: 67_109_891,   field: :P3Leistung,             type: :float },
    # Analogeingänge
    { name: 'Analogeingang1',         dxs_id: 167_772_417,  field: :Analogeingang1,         type: :float },
    { name: 'Analogeingang2',         dxs_id: 167_772_673,  field: :Analogeingang2,         type: :float },
    { name: 'Analogeingang3',         dxs_id: 167_772_929,  field: :Analogeingang3,         type: :float },
    { name: 'Analogeingang4',         dxs_id: 167_773_185,  field: :Analogeingang4,         type: :float },
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
