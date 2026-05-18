class FluxWriter
  def initialize(config)
    @config = config
  end

  attr_reader :config

  def ready?
    influx_client.ping.status == 'ok'
  end

  def push(fields:, measure_time:)
    write_api.write(
      data: point(fields:, measure_time:),
      bucket: config.influx_bucket,
      org: config.influx_org,
    )
  end

  private

  def point(fields:, measure_time:)
    InfluxDB2::Point.new(
      name: config.influx_measurement,
      time: measure_time,
      fields:,
    )
  end

  def influx_client
    @influx_client ||=
      InfluxDB2::Client.new(
        config.influx_url,
        config.influx_token,
        use_ssl: config.influx_schema == 'https',
        precision: InfluxDB2::WritePrecision::SECOND,
      )
  end

  def write_api
    @write_api ||= influx_client.create_write_api
  end
end
