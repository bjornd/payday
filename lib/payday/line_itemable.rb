# Include this module into your line item implementation to make sure that Payday stays happy
# with it, or just make sure that your line item implements the amount method.
module Payday::LineItemable
  # Returns the total amount for this {LineItemable}, or +price * quantity+
  def amount
    amount_subtotal - discount
  end
  
  def amount_subtotal
    price * quantity
  end
  
  def discount
    if discounts.empty?
      0
    else
      amount_subtotal - Payday::Discount.apply_discounts(quantity, amount_subtotal, discounts).last[:amount]
    end
  end
end