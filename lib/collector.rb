require 'loop'

class Collector
  def initialize(config:, client: nil, influx_push: nil, max_wait: 12)
    @config = config
    @max_wait = max_wait
  end

  def run(max_count: nil)
    Loop.start(config:, max_count:, max_wait:)
  end

  private

  attr_reader :config, :max_wait
end
