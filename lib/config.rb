require 'kostal_metrics'

Config = Data.define(:host, :protocol, :port, :interval, :metrics, :logger) do
  def self.from_env
    new(
      host: ENV.fetch('KOSTAL_HOST', 'kostal'),
      protocol: ENV.fetch('KOSTAL_PROTOCOL', 'http'),
      port: ENV.fetch('KOSTAL_PORT', '80').to_i,
      interval: ENV.fetch('KOSTAL_INTERVAL', '10').to_i,
      metrics: KostalMetrics::DEFAULT_METRICS,
      logger: nil,
    )
  end

  def base_url
    "#{protocol}://#{host}:#{port}"
  end
end
