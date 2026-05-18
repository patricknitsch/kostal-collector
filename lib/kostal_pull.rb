require 'kostal_client'
require 'kostal_metrics'
require 'kostal_record'

class KostalPull
  def initialize(config:, queue:, client: nil)
    @queue = queue
    @config = config
    @client = client || KostalClient.new(config:)
    @count = 0
  end

  attr_reader :config, :queue, :client, :count

  def next
    values_by_name = client.fetch
    fields = KostalMetrics.to_influx_fields(config.metrics, values_by_name)
    @count += 1
    record = KostalRecord.new(@count, { measure_time: Time.now.to_i, **fields })
    queue << record
    logger.info "Got record ##{record.id}"
    record
  end

  private

  def logger
    config.logger
  end
end
