require 'flux_writer'
require 'forwardable'
require 'influxdb-client'
require 'kostal_metrics'

class InfluxPush
  extend Forwardable

  def_delegators :config, :logger

  def initialize(config:, flux_writer: nil)
    @config = config
    @flux_writer = flux_writer || FluxWriter.new(config)
  end

  attr_reader :config, :flux_writer

  def ready?
    flux_writer.ready?
  rescue StandardError => e
    logger&.error("InfluxDB not ready: #{e.message}")
    false
  end

  def push(values_by_name)
    fields = KostalMetrics.to_influx_fields(config.metrics, values_by_name)
    return if fields.empty?

    flux_writer.push(fields:, measure_time: Time.now.to_i)
    logger&.info('Successfully pushed record to InfluxDB')
  rescue StandardError => e
    logger&.error("Error while pushing record to InfluxDB: #{e.message}")
  end
end
