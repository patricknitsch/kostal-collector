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
    if config.metrics.empty?
      logger.info 'No metrics configured via KOSTAL_METRICS - skipping poll cycle.'
      return
    end

    values_by_name = client.fetch
    fields = KostalMetrics.to_influx_fields(config.metrics, values_by_name)
    if fields.empty?
      logger.info 'No configured fields found in API response - skipping publish.'
      return
    end

    @count += 1
    record = KostalRecord.new(@count, { measure_time: Time.now.to_i, **fields })
    queue << record
    logger.info "Record ##{record.id}: #{fields.map { |k, v| "#{k}=#{v}" }.join(', ')}"
    record
  end

  private

  def logger
    config.logger
  end
end
