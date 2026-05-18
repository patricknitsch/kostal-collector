require 'kostal_client'
require 'influx_push'

class Collector
  def initialize(config:, client: nil, influx_push: nil)
    @config = config
    @client = client || KostalClient.new(config:)
    @influx_push = influx_push || InfluxPush.new(config:)
  end

  def run(max_count: nil)
    count = 0

    return unless influx_push.ready?

    loop do
      collect_once
      count += 1
      break if max_count && count >= max_count

      sleep config.interval
    end
  end

  def collect_once
    values = client.fetch
    config.logger&.info(values.map { |name, value| "#{name}=#{value}" }.join(', '))
    influx_push.push(values)
    values
  rescue StandardError => e
    config.logger&.error("Error collecting Kostal data: #{e.message}")
    nil
  end

  private

  attr_reader :config, :client, :influx_push
end
