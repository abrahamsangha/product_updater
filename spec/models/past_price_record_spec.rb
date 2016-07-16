require 'rails_helper'

RSpec.describe PastPriceRecord, type: :model do
  it { should validate_presence_of(:product) }
end
