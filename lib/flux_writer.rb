require 'net/http'
require 'uri'

class FluxWriter
  def initialize(config)
    @config = config
  end

  attr_reader :config

  def ready?
    response = Net::HTTP.get_response(URI("#{config.influx_url}/ping"))
    return true if response.code.to_i == 204

    config.logger.error "\nInfluxDB ping failed: HTTP #{response.code} #{response.message}"
    false
  rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::EHOSTUNREACH => e
    config.logger.error "\nInfluxDB unreachable: #{e.message}"
    false
  end

  def push(record)
    write_api.write(
      data: point(record),
      bucket: config.influx_bucket,
      org: config.influx_org,
    )
  end

  private

  def point(record)
    InfluxDB2::Point.new(
      name: config.influx_measurement,
      time: record.measure_time,
      fields: record.to_hash,
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
