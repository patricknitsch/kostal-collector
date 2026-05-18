#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require

$LOAD_PATH.unshift(File.expand_path('./lib', __dir__))

require 'config'
require 'loop'
require 'stdout_logger'

logger = StdoutLogger.new

logger.info 'Kostal collector for SOLECTRUS, ' \
       "Version #{ENV.fetch('VERSION', '<unknown>')}, " \
       "built at #{ENV.fetch('BUILDTIME', '<unknown>')}"
logger.info 'https://github.com/patricknitsch/kostal-collector'
logger.info 'Based on https://github.com/solectrus/senec-collector'
logger.info "\n"

config = Config.from_env
config.logger = logger

logger.info "Using Ruby #{RUBY_VERSION} on platform #{RUBY_PLATFORM}"
logger.info "Pushing to InfluxDB at #{config.influx_url}, " \
       "bucket #{config.influx_bucket}, " \
       "measurement #{config.influx_measurement}"
logger.info "Pulling from Kostal at #{config.base_url} every #{config.interval}s"
logger.info "\n"

Loop.start(config:)
