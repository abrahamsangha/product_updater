class Product < ActiveRecord::Base
  has_many :past_price_records
  validates :external_product_id, uniqueness: true, presence: true
  validates :price, numericality: { only_integer: true }
  validates :name, presence: true

end
