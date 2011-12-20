module Payday
  class Discount

    attr_accessor :kind, :unit, :amount

    def initialize(options = {})
      self.kind = options[:kind] || "percentage" # value|percentage|free
      self.unit = options[:unit] || "money" # quantity|money
      self.amount = options[:amount] || 0
    end
    
    def calculate(value)
      case kind
      when 'value'
        amount > value ? value : amount
      when 'percentage'
        value * amount / 100.0
      when 'free'
        value
      end
    end
    
    def description(invoice)
      case kind
      when 'value'
        Payday::PdfRenderer.number_to_currency(amount, invoice)
      when 'percentage'
        amount.to_s+'%'
      when 'free'
        'free'
      end
    end
    
    def self.apply_discounts(quantity, amount, discounts)
      sequence = []
      discounts.each do |discount|
        if discount.unit == 'quantity'
          discount_amount = discount.calculate(amount)
          price = amount/quantity
          amount -= discount_amount
          quantity -= discount_amount/price
        else
          amount -= discount.calculate(amount)
        end
        amount = 0 if amount < 0
        quantity = 0 if quantity < 0
        sequence << {amount: amount, quantity: quantity}
        break if amount == 0 || quantity == 0
      end
      sequence 
    end
  end
end