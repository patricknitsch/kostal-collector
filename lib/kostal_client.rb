require 'json'
require 'net/http'
require 'uri'
require 'kostal_metrics'

class KostalClient
  def initialize(config:, http_get: Net::HTTP.method(:get_response))
    @config = config
    @http_get = http_get
  end

  def fetch
    response = http_get.call(uri)
    code = response.code.to_i
    raise "Unexpected response from Kostal API: #{response.code}" unless code.between?(200, 299)

    payload = JSON.parse(response.body)
    entries = payload.fetch('dxsEntries', [])

    KostalMetrics.to_lookup(config.metrics, entries)
  end

  private

  attr_reader :config, :http_get

  def uri
    joined_ids = config.metrics.map { |metric| metric.fetch(:dxs_id) }.join(',')
    URI("#{config.base_url}/api/dxs.json?dxsEntries=#{joined_ids}")
  end
end
