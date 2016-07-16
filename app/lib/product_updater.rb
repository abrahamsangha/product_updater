require 'apis/product_api'

module ProductUpdater
  extend self

  def execute
    new_product_records.each do |record|
      matching_product = Product.find_by(external_product_id: record['id'])
      if matching_product.nil?
        if not_discontinued?(record)
          Product.create(create_args(record))
        end
      elsif same_name?(matching_product, record)
        if different_price?(matching_product.price, price(record['price']))
          ActiveRecord::Base.transaction do
            create_past_price_record(matching_product, price(record['price']))
            matching_product.update(price: price(record['price']))
          end
        end
      else
        log_mismatch(matching_product.id)
      end
    end
  end

  def create_args(record)
    record.except('id','category', 'discontinued', 'price').
      merge(external_product_id: record['id'],
            price: price(record['price']))
  end

  def past_price_record_args(product, new_price)
    {
      product_id: product.id,
      price: product.price,
      percentage_change: percentage_change(product.price, new_price)
    }
  end

  def percentage_change(old_price, new_price)
    (new_price - old_price) / old_price.to_f * 100
  end

  def create_past_price_record(product, new_price)
     PastPriceRecord.create(past_price_record_args(product, new_price))
  end


  def price(unformatted)
    (unformatted.gsub('$','').to_f * 100).to_i
  end

  def not_discontinued?(args)
    !args['discontinued']
  end

  def same_name?(product, new_record)
    product.name == new_record['name']
  end

  def different_price?(old_price, new_price)
    old_price != new_price
  end

  def new_product_records
    @new_product_records ||= ProductApi.default.product_records
  end

  def log_mismatch(id)
    Rails.logger.info "Product name mismatch between api response and our record for" \
                 "Product id: #{id}"
  end

end
