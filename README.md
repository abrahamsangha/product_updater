You are working on a Rails 4.2 project that tracks sales information for different products. You are writing code that will contact a vendor, Omega Pricing Inc - "The Last Word In Pricing" - to get new pricing information for several products.

You have a Product model that has an id, an external_product_id (which is the id that external vendors, such as Omega Pricing, uses), a price (in pennies), and a product_name. It has the normal ActiveRecord created_at and updated_at timestamps.

Each product has_many :past_price_records. A PastPriceRecord is a record of what the price of something used to be. It has an id, a product_id (belongs_to :product), a price (again in pennies), and a percentage_change, which is a float. It also has the normal ActiveRecord created_at and updated_at timestamps.

Your API key for Omega Pricing is "abc123key".
Your company will update these records monthy, and you are helping with the code that will make the RESTful calls to Omega Pricing's API.

Please write code that does the following:
1) makes a GET call to https://omegapricinginc.com/pricing/records.json and passes the following as URL params:
  * your API key as api_key
  * a start_date of one month ago
  * an end_date of today
You may use gems to help with making the call.

2) Their JSON endpoint will return records like this:
{
  productRecords: [
    {
      id: 123456,
      name: "Nice Chair",
      price: "$30.25",
      category: "home-furnishings",
      discontinued: false
    },
    {
      id: 234567,
      name: "Black & White TV",
      price: "$43.77",
      category: "electronics",
      discontinued: true
    },
    ...
  ]
}

Please update all your Product records as follows:
  * If you have a Product with an external_product_id that matches their id and it has the same name and the price is different, create a new PastPriceRecord for your Product. Then update the Product's price. Do this even if the item is discontinued.

  * If you do not have a Product with that external_product_id and the product is not discontinued, create a new Product record for it. Explicitly log that there is a new product and that you are creating a new product.

  * if you have a Product record with a matching external_product_id but a different product name, log an error message that warns the team that there is a mismatch. Do not update the price.

If you need to make any assumptions as you code, please record what they are. If you use any gems to help, please note what they are and how they helped with solving the problem.
