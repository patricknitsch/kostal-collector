require 'spec_helper'
require 'config'
require 'kostal_client'

describe KostalClient do
  let(:config) do
    Config.new(
      host: 'example.com',
      protocol: 'http',
      port: 80,
      interval: 10,
      metrics: KostalMetrics::DEFAULT_METRICS,
      logger: nil,
    )
  end

  describe '#fetch' do
    it 'requests configured dxs IDs and maps response values' do
      requested_uri = nil
      response = Struct.new(:code, :body).new(
        '200',
        {
          dxsEntries: [
            { dxsId: 67_109_120, value: 1234 },
            { dxsId: 16_780_032, value: 0 },
          ],
        }.to_json,
      )

      client = described_class.new(
        config:,
        http_get: lambda { |uri|
          requested_uri = uri
          response
        },
      )

      values = client.fetch

      expect(requested_uri.to_s).to include('/api/dxs.json?dxsEntries=')
      expect(values['ID_Ausgangsleistung']).to eq(1234)
      expect(values['ID_Status']).to eq(0)
    end
  end
end
