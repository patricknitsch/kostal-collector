#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path('./lib', __dir__))

require 'collector'
require 'config'
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
logger.info "Pulling from Kostal at #{config.base_url} every #{config.interval} seconds"
logger.info "\n"

Collector.new(config:).run
