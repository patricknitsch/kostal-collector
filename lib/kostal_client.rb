require 'json'
require 'net/http'
require 'uri'
require 'kostal_metrics'

class KostalClient
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10

  def initialize(config:, http_get: nil)
    @config = config
    @http_get = http_get || method(:http_get_with_timeout)
  end

  def fetch
    logger.info "Fetching from #{uri}"
    response = http_get.call(uri)
    code = response.code.to_i
    unless code.between?(200, 299)
      raise "Unexpected response from Kostal API: #{response.code} - #{response.body}"
    end

    logger.info "Kostal responded: HTTP #{response.code}"
    payload = JSON.parse(response.body)
    entries = payload.fetch('dxsEntries', [])

    KostalMetrics.to_lookup(config.metrics, entries)
  end

  private

  attr_reader :config, :http_get

  def logger
    config.logger
  end

  def uri
    query = config.metrics.map { |m| "dxsEntries=#{m.fetch(:dxs_id)}" }.join('&')
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
