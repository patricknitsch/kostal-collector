require 'forwardable'
require 'influx_push'
require 'kostal_pull'

class Loop
  extend Forwardable

  def_delegators :config, :logger

  def self.start(config:, max_count: nil, max_wait: 12)
    new(config:, max_count:, max_wait:).start
  end

  def initialize(config:, max_count:, max_wait:)
    @config = config
    @max_count = max_count
    @max_wait = max_wait
  end

  attr_reader :config, :max_count, :max_wait
  attr_accessor :queue

  def start
    self.queue = Queue.new
    return unless influx_ready?(max_wait)

    pull_thread = Thread.new { pull_loop }
    push_thread = Thread.new { push_loop }

    pull_thread.join
    close_queue
    push_thread.join
  rescue SystemExit, Interrupt
    logger.error 'Exiting...'
    pull_thread&.exit
    close_queue
    push_thread&.exit
  end

  private

  def pull_loop
    loop do
      kostal_pull.next
      break if max_count && kostal_pull.count >= max_count

      sleep config.interval
    end
  rescue StandardError => e
    logger.error "Error getting data from Kostal: #{e.message}"
  end

  def influx_ready?(max_wait)
    logger.info 'Wait until InfluxDB is ready ...', newline: false

    count = 0
    until (ready = influx_push.ready?) || (max_wait && count >= max_wait)
      logger.info '.', newline: false
      count += 1
      sleep 5
    end

    if ready
      logger.info ' OK'
      logger.info ''
      true
    else
      logger.error "\nInfluxDB not ready after #{count * 5} seconds - aborting."
      false
    end
  end

  def push_loop
    influx_push.run
  end

  def close_queue
    until queue.empty?
      logger.info "Waiting for #{queue.size} records to be pushed to InfluxDB"
      sleep 1
    end

    queue.close
  end

  def influx_push
    @influx_push ||= InfluxPush.new(config:, queue:)
  end

  def kostal_pull
    @kostal_pull ||= KostalPull.new(config:, queue:)
  end
end
