require 'httparty'
require 'active_support'
require 'active_support/core_ext/date/calculations'

class ProductApi
  include HTTParty
  attr_reader :product_api_root_uri, :options

  def initialize(product_api_root_uri:, api_key:, start_date:, end_date:)
    @product_api_root_uri = product_api_root_uri
    @options = { api_key: api_key, start_date: start_date, end_date: end_date }
  end

  def self.default
    @default_api ||= new(
      product_api_root_uri: ENV['PRODUCT_API_ROOT_URI'],
      api_key: ENV['PRODUCT_API_KEY'],
      start_date: Date.current.prev_month,
      end_date: Date.current)
  end

  def find_all
    self.class.get(product_api_root_uri, { query: options })
  end
end
