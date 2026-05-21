require 'forwardable'
require 'influx_push'
require 'kostal_pull'
require 'mqtt_push'

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
    return unless output_ready?(max_wait)

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

  def output_ready?(max_wait)
    logger.info "Wait until #{output_name} is ready ...", newline: false

    count = 0
    until (ready = push_target.ready?) || (max_wait && count >= max_wait)
      logger.info '.', newline: false
      count += 1
      sleep 5
    end

    if ready
      logger.info ' OK'
      logger.info ''
      true
    else
      logger.error "\n#{output_name} not ready after #{count * 5} seconds - aborting."
      false
    end
  end

  def push_loop
    push_target.run
  end

  def close_queue
    loop do
      pending = queue.size
      break if pending.zero?

      logger.info "Waiting for #{pending} records to be pushed to #{output_name}"
      sleep 1
    end

    queue.close
  end

  def push_target
    @push_target ||=
      if config.mqtt_output?
        MqttPush.new(config:, queue:)
      else
        InfluxPush.new(config:, queue:)
      end
  end

  def output_name
    config.mqtt_output? ? 'MQTT broker' : 'InfluxDB'
  end

  def kostal_pull
    @kostal_pull ||= KostalPull.new(config:, queue:)
  end
end
