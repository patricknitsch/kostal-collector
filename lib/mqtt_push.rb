require 'forwardable'
require 'mqtt'

class MqttPush
  extend Forwardable

  def_delegators :config, :logger

  def initialize(config:, queue:, retry_sleep: 5)
    @config = config
    @queue = queue
    @retry_sleep = retry_sleep
  end

  attr_reader :config, :queue, :retry_sleep

  def ready?
    with_client { true }
  rescue StandardError => e
    logger.error "MQTT broker not ready: #{e.class}: #{e.message}"
    false
  end

  def run
    until queue.closed?
      record = queue.pop
      push(record) if record
    end
  end

  private

  def push(record)
    with_client do |client|
      payload = record.to_hash
      publish_fields(client, payload)
      logger.info "Successfully pushed record ##{record.id} to MQTT"
    end
  rescue StandardError => e
    error_handling(record, e)
    sleep(retry_sleep)
  end

  def publish_fields(client, payload)
    measure_time = payload[:measure_time]
    publish(client, "#{config.mqtt_topic_prefix}/measure_time", measure_time)

    payload.each do |field, value|
      next if field == :measure_time || value.nil?

      publish(client, "#{config.mqtt_topic_prefix}/#{field}", value)
    end
  end

  def publish(client, topic, value)
    client.publish(topic, value.to_s, config.mqtt_retain)
  end

  def error_handling(record, error)
    logger.error "Error while pushing record ##{record.id} to MQTT: #{error.class}: #{error.message}"
    logger.error "  Host:   #{config.mqtt_host}"
    logger.error "  Port:   #{config.mqtt_port}"
    logger.error "  Prefix: #{config.mqtt_topic_prefix}"
    return if queue.closed?

    queue << record
    logger.info "The record has been queued. Will retry to push #{queue.size} records later."
  end

  def with_client
    MQTT::Client.connect(
      host: config.mqtt_host,
      port: config.mqtt_port,
      username: config.mqtt_username.to_s.empty? ? nil : config.mqtt_username,
      password: config.mqtt_password.to_s.empty? ? nil : config.mqtt_password,
    ) do |client|
      return yield(client)
    end
  end
end
