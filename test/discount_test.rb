require File.expand_path("test/test_helper")

module Payday
  class DiscountTest < MiniTest::Unit::TestCase

    test "that setting values through the options hash on initialization works" do
      d = Discount.new(:kind => 'free', :unit => 'quantity', :amount => 10)
      
      assert_equal d.kind, 'free'
      assert_equal d.unit, 'quantity'
      assert_equal d.amount, 10
    end
    
    test "that discounts are calculated properly" do
      discountValue = Discount.new(:kind => 'value', :unit => 'money', :amount => 10)
      discountPercentage = Discount.new(:kind => 'percentage', :unit => 'money', :amount => 30)
      discountFree = Discount.new(:kind => 'free', :unit => 'money')
      
      assert_equal discountValue.calculate(100), 10
      assert_equal discountValue.calculate(1), 1
      assert_equal discountPercentage.calculate(100), 30
      assert_equal discountPercentage.calculate(1), 0.3
      assert_equal discountFree.calculate(100), 100
    end
    
    test "that several discounts apply properly" do
      discounts = [
        Discount.new(:kind => 'value', :unit => 'money', :amount => 10),
        Discount.new(:kind => 'percentage', :unit => 'money', :amount => 10)
      ]
      sequence = Discount.apply_discounts(10, 100, discounts)
      
      assert_equal [{:amount => 90, :quantity => 10}, {:amount => 81, :quantity => 10}], sequence
    end
    
    test "that discount can't be more then 100%" do
      discounts = [
        Discount.new(:kind => 'free', :unit => 'money'),
        Discount.new(:kind => 'percentage', :unit => 'money', :amount => 10)
      ]
      sequence = Discount.apply_discounts(10, 100, discounts)
      
      assert_equal [{:amount => 0, :quantity => 10}], sequence
    end
    
    test "that free discount is applied properly" do
      sequence = Discount.apply_discounts(10, 100, [Discount.new(:kind => 'free', :unit => 'money')])
      assert_equal [{:amount => 0, :quantity => 10}], sequence
      sequence = Discount.apply_discounts(10, 100, [Discount.new(:kind => 'free', :unit => 'quantity')])
      assert_equal [{:amount => 0, :quantity => 0}], sequence
    end
    
    test "that quantity and money discounts are combined properly" do
      discounts = [
        Discount.new(:kind => 'percentage', :unit => 'money', :amount => 10),
        Discount.new(:kind => 'percentage', :unit => 'quantity', :amount => 10)
      ]
      sequence = Discount.apply_discounts(10, 100, discounts)
      assert_equal [{:amount => 90, :quantity => 10}, {:amount => 81, :quantity => 9}], sequence
    end
    
    test "that quantity value discount is aplied properly" do
      discounts = [
        Discount.new(:kind => 'value', :unit => 'quantity', :amount => 2)
      ]
      sequence = Discount.apply_discounts(10, 100, discounts)
      assert_equal [{:amount => 80, :quantity => 8}], sequence
    end
  end
end
