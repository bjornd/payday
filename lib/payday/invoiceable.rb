# Include {Payday::Invoiceable} in your Invoice class to make it Payday compatible. Payday
# expects that a +line_items+ method containing an Enumerable of {Payday::LineItem} compatible
# elements exists. Those LineItem objects primarily need to include quantity, price, and description methods.
#
# The +bill_to+ method should always be overwritten by your class. Otherwise, it'll say that your invoice should
# be billed to Goofy McGoofison. +ship_to+ is also available, but will not be used in rendered invoices if it
# doesn't exist.
#
# Although not required, if a +tax_rate+ method exists, {Payday::Invoiceable} will use it to calculate tax
# when generating an invoice. We include a simple tax method that calculates tax, but it's probably wiser
# to override this in your class (our calculated tax won't be stored to a database by default, for example).
#
# If the +due_at+ and +paid_at+ methods are available, {Payday::Invoiceable} will use them to show due dates and
# paid dates, as well as stamps showing if the invoice is paid or due.
module Payday::Invoiceable
  
  # Who the invoice is being sent to.
  def bill_to
    "Goofy McGoofison\nYour Invoice Doesn't\nHave It's Own BillTo Method"
  end
  
  # Calculates the subtotal of this invoice by adding up all of the line items
  def subtotal
    line_items.inject(BigDecimal.new("0")) { |result, item| result += item.amount }
  end
  
  # Calculates the total quantity of invoice items
  def quantity
    line_items.inject(BigDecimal.new("0")) { |result, item| result += item.quantity - item.quantity_discount }
  end
  
  # The tax for this invoice, as a BigDecimal
  def tax
    if defined?(tax_rate)
      calculated = (subtotal - discount) * tax_rate
      return 0 if calculated < 0
      calculated
    else
      0
    end
  end
  
  # TODO Add a per weight unit shipping cost
  # Calculates the shipping
  def shipping
    if defined?(shipping_rate)
      shipping_rate
    else
      0
    end
  end
  
  def discount
    if discounts.empty?
      0
    else
      subtotal - Payday::Discount.apply_discounts(quantity, subtotal, discounts).last[:amount]
    end
  end
  
  def quantity_discount
    if discounts.empty?
      0
    else
      quantity - Payday::Discount.apply_discounts(quantity, subtotal, discounts).last[:quantity]
    end
  end
  
  # Calculates the total for this invoice.
  def total
    subtotal + tax + shipping - discount
  end
  
  def overdue?
    defined?(:due_at) && ((due_at.is_a?(Date) && due_at < Date.today) || (due_at.is_a?(Time) && due_at < Time.now))  && !paid_at
  end
  
  def paid?
    defined?(:paid_at) && !!paid_at
  end
  
  # Renders this invoice to pdf as a string
  def render_pdf
    Payday::PdfRenderer.render(self)
  end
  
  # Renders this invoice to pdf
  def render_pdf_to_file(path)
    Payday::PdfRenderer.render_to_file(self, path)
  end
  
  # Iterates through the details on this invoiceable. The block given should accept
  # two parameters, the detail name and the actual detail value.
  def each_detail(&block)
    return if defined?(invoice_details).nil?
    
    invoice_details.each do |detail|
      block.call(detail[0], detail[1])
    end
  end
end