require 'rails_helper'

RSpec.describe ProductUpdater do
  subject(:updater) { ProductUpdater }
  let(:product_api_class) do class_double('ProductApi').
                              as_stubbed_const(transfer_nested_constants: true)
  end
  let(:product_api) { instance_double('ProductApi') }
  let(:past_price_record) { PastPriceRecord.find_by(price: args[:price]) }
  before do
    allow(product_api_class).to receive(:default).and_return(product_api)
    allow(product_api).to receive(:product_records).and_return(response)
  end

  def product_by_name(name)
    Product.find_by(name: name)
  end

  context 'with a non-matching' do
    context 'and non-discontinued record' do
      let(:response) do [{
          'id' => 234567,
          'name' => 'Black & White TV',
          'price' => '$43.77',
          'category' =>  'electronics',
          'discontinued' => false
        }]
      end
      it 'creates a new Product' do
        expect(Product.count).to eq 0
        updater.execute
        expect(product_by_name('Black & White TV')).not_to be_nil
        expect(Product.count).to eq 1
      end

      it 'logs the new product' do
        expect(Rails.logger).to receive(:info).with(/new/).twice
        updater.execute
      end
    end

    context 'and discontinued record' do
      let(:response) do [{
          'id' => 999999,
          'name' => 'Replicator',
          'price' => '$873492.38',
          'category' =>  'star trek',
          'discontinued' => true
        }]
      end
      it 'does not create a new Product' do
        expect(Product.count).to eq 0
        updater.execute
        expect(product_by_name('Replicator')).to be_nil
        expect(Product.count).to eq 0
      end

      it 'does not log a new product' do
        expect(Rails.logger).not_to receive(:info).with /new/
        updater.execute
      end
    end
  end

  context 'with a matching record' do
    context 'and the same name' do
      context 'and a different price' do
        context 'and discontinued' do
          let(:args) { { external_product_id: 234567,
                         name: "Black & White TV",
                         price: 4000 } }
          let(:response) do [{
              'id' => 234567,
              'name' => 'Black & White TV',
              'price' => '$43.77',
              'category' =>  'electronics',
              'discontinued' => true
            }]
          end

          before do
            Product.create!(args)
            updater.execute
          end

          it 'creates a PastPriceRecord' do
            expect(past_price_record).not_to be_nil
          end

          it 'updates the price for the Product record' do
            expect(product_by_name('Black & White TV').price).to eq 4377
          end
        end

        context 'and not discontinued' do
          let(:args) { { external_product_id: 234567,
                         name: "Black & White TV",
                         price: 4000 } }
          let(:response) do [{
              'id' => 234567,
              'name' => 'Black & White TV',
              'price' => '$43.77',
              'category' =>  'electronics',
              'discontinued' => false
            }]
          end

          before do
            Product.create!(args)
            updater.execute
          end

          it 'creates a PastPriceRecord' do
            expect(past_price_record).not_to be_nil
          end

          it 'updates the price for the Product record' do
            expect(product_by_name('Black & White TV').price).to eq 4377
          end
        end
      end

      context 'and the same price' do
        let(:args) { { external_product_id: 234567,
                     name: "Black & White TV",
                     price: 4377 } }
        let(:response) do [{
            'id' => 234567,
            'name' => 'Black & White TV',
            'price' => '$43.77',
            'category' =>  'electronics',
            'discontinued' => true
          }]
        end
        before do
          Product.create!(args)
          updater.execute
        end

        it 'does not create a PastPriceRecord' do
          expect(past_price_record).to be_nil
          expect(PastPriceRecord.count).to eq 0
        end
      end
    end

    context 'and a different name' do
      let(:args) { { external_product_id: 234567,
                   name: 'Color TV',
                   price: 4377 } }
      let(:response) do [{
          'id' => 234567,
          'name' => 'Black & White TV',
          'price' => '$34.88',
          'category' =>  'electronics',
          'discontinued' => true
        }]
      end

      before do
        Product.create!(args)
      end

      it 'logs the mismatch' do
        expect(Rails.logger).to receive(:info).with /mismatch/
        updater.execute
      end

      it 'does not update the price' do
        expect(product_by_name('Color TV').price).to eq 4377
      end

      it 'does not create a new Product' do
        expect(Product.count).to eq 1
        updater.execute
        expect(Product.count).to eq 1
      end

      it 'does not create a PastPriceRecord' do
        expect(past_price_record).to be_nil
        expect(PastPriceRecord.count).to eq 0
      end
    end

  end
end

