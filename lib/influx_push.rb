require 'flux_writer'
require 'forwardable'
require 'influxdb-client'

class InfluxPush
  extend Forwardable

  def_delegators :config, :logger

  def initialize(config:, queue:, flux_writer: nil, retry_sleep: 5)
    @config = config
    @queue = queue
    @flux_writer = flux_writer || FluxWriter.new(config)
    @retry_sleep = retry_sleep
  end

  attr_reader :config, :queue, :flux_writer, :retry_sleep

  def ready?
    flux_writer.ready?
  end

  def run
    until queue.closed?
      record = queue.pop
      push(record) if record
    end
  end

  private

  def push(record)
    flux_writer.push(record)
    logger.info "Successfully pushed record ##{record.id} to InfluxDB"
  rescue StandardError => e
    error_handling(record, e)
    sleep(retry_sleep)
  end

  def error_handling(record, error)
    logger.error "Error while pushing record ##{record.id} to InfluxDB: #{error.message}"
    return if queue.closed?

    queue << record
    logger.info "The record has been queued. Will retry to push #{queue.size} records later."
  end
end
