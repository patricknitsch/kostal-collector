require 'spec_helper'
require 'kostal_pull'

describe KostalPull do
  let(:logger) { double('Logger', info: nil, error: nil) }
  let(:config) { build_config(logger:) }
  let(:queue) { Queue.new }
  let(:client) { instance_double(KostalClient, fetch: { 'ID_Ausgangsleistung' => '1234', 'ID_Status' => '2' }) }

  subject(:kostal_pull) { described_class.new(config:, queue:, client:) }

  describe '#next' do
    it 'creates and queues an incrementing record' do
      allow(Time).to receive(:now).and_return(Time.at(1_700_000_000))

      record = kostal_pull.next

      expect(record.id).to eq(1)
      expect(record.to_hash).to include(measure_time: 1_700_000_000, ac_output_power: 1234.0, status: 2)
      expect(queue.pop).to eq(record)
    end
  end
end
