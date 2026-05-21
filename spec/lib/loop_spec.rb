require 'spec_helper'
require 'loop'

describe Loop do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) { build_config(interval: 1, logger:) }
  let(:record) { instance_double(KostalRecord) }
  let(:kostal_pull) { instance_double(KostalPull, next: record, count: 1) }
  let(:push_target) { instance_double(InfluxPush, ready?: true, run: true) }
  let(:loop_instance) { described_class.new(config:, max_count: 1, max_wait: 0) }

  before do
    allow(loop_instance).to receive(:kostal_pull).and_return(kostal_pull)
    allow(loop_instance).to receive(:push_target).and_return(push_target)
  end

  describe '#start' do
    it 'returns when output target is not ready' do
      allow(push_target).to receive(:ready?).and_return(false)
      allow(loop_instance).to receive(:sleep)

      loop_instance.start

      expect(kostal_pull).not_to have_received(:next)
    end

    it 'runs pull and push loops when output target is ready' do
      loop_instance.start

      expect(kostal_pull).to have_received(:next).once
      expect(push_target).to have_received(:run).once
      expect(loop_instance.queue.closed?).to be(true)
    end
  end
end
