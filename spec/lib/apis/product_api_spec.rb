require 'apis/product_api'
require 'webmock/rspec'
require 'fixtures/product_api_response'

RSpec.describe ProductApi do
  subject(:api) { ProductApi.default }
  describe '#find_all' do
    let(:response) { api.find_all }
    before do
      stub_request(:get, 'https://omegapricinginc.com/pricing/records.json').
        with(query: { 'api_key' => 'abc123key',
                      'start_date' => Date.current.prev_month,
                      'end_date' => Date.current }).
        to_return(status: 200,
                  body: PRODUCT_API_RESPONSE)
    end

    it 'makes a successful request to the correct root uri' do
      expect(response.code).to eq 200
    end

    it 'passes the correct url params' do
      expect(response.request.options[:query][:api_key]).to eq 'abc123key'
      expect(response.request.options[:query][:start_date]).to eq Date.current.prev_month
      expect(response.request.options[:query][:end_date]).to eq Date.current
    end
  end

  describe '#product_records' do
    let(:product_list) do
      [
        {
          'id' => 123456,
          'name' => 'Nice Chair',
          'price' => '$30.25',
          'category' => 'home-furnishings',
          'discontinued' => false
        },
        {
          'id' => 234567,
          'name' => 'Black & White TV',
          'price' => '$43.77',
          'category' =>  'electronics',
          'discontinued' => true
        }
      ]
    end
    before do
      allow(api).to receive(:find_all).and_return(PRODUCT_API_RESPONSE)
    end

    it 'returns a list of product records' do
      expect(api.product_records).to eq product_list
    end
  end

end
