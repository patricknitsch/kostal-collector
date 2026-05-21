require 'json'
require 'net/http'
require 'uri'
require 'kostal_metrics'

class KostalClient
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10
  BATCH_SIZE = 10

  def initialize(config:, http_get: nil)
    @config = config
    @http_get = http_get || method(:http_get_with_timeout)
  end

  def fetch
    metrics = config.metrics
    batches = metrics.each_slice(BATCH_SIZE).to_a
    logger.info "Fetching #{metrics.size} metrics in #{batches.size} batch(es) from #{config.base_url}"

    batches.each_with_object({}) do |batch, result|
      result.merge!(fetch_batch(batch))
    end
  end

  private

  attr_reader :config, :http_get

  def logger
    config.logger
  end

  def fetch_batch(metrics)
    u = batch_uri(metrics)
    response = http_get.call(u)
    code = response.code.to_i
    unless code.between?(200, 299)
      raise "Unexpected response from Kostal API: #{response.code} - #{response.body}"
    end

    logger.info "Kostal responded: HTTP #{response.code} (#{metrics.size} entries)"
    payload = JSON.parse(response.body)
    entries = payload.fetch('dxsEntries', [])

    KostalMetrics.to_lookup(metrics, entries)
  end

  def batch_uri(metrics)
    query = metrics.map { |m| "dxsEntries=#{m.fetch(:dxs_id)}" }.join('&')
    URI("#{config.base_url}/api/dxs.json?#{query}")
  end

  def http_get_with_timeout(uri)
    Net::HTTP.start(uri.host, uri.port,
                    open_timeout: OPEN_TIMEOUT,
                    read_timeout: READ_TIMEOUT) do |http|
      http.request(Net::HTTP::Get.new(uri.request_uri))
    end
  end
end
