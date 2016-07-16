class PastPriceRecord < ActiveRecord::Base
  belongs_to :product
  validates :price, numericality: { only_integer: true }
  validates :percentage_change, numericality: true
  validates :product, presence: true
end
