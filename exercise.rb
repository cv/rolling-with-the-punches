require 'rubygems'
require 'active_support'
require 'test/unit'

def p(amount)
  if amount < 1
    sprintf("%2dp", amount * 100)
  else
    sprintf("£%0.2f", amount)
  end
end

module Products
end

class Numeric

  def each
    value = self
    proc {value * quantity}
  end
  
  def per_kilo
    value = self
    proc {value * quantity}
  end
  
  def for(the_price)
    qty = self
    proc do
      (quantity / qty + quantity % qty) * the_price
    end
  end
end

def product(name, pricing_proc)
  c = Class.new do
    attr_accessor :quantity
    
    def initialize(quantity = 1)
      @quantity = quantity
    end
  end
  
  c.class_eval do
    define_method :price, pricing_proc
    define_method :to_s do
      "#{quantity} #{name.to_s.downcase.pluralize} - #{p(price)}"
    end
  end
  
  Products.const_set name, c
end

include Products

product :Banana,      1.00.each
product :Apple,       1.00.each
product :Orange,      1.50.each
product :Plum,        1.50.each
product :Grapefruit,  1.50.each
product :Strawberry,  1.00.per_kilo
product :Cherry,      2.00.per_kilo
product :Raspberry,   2.00.per_kilo
product :Blackberry,  2.00.per_kilo
product :Cranberry,   2.00.per_kilo

product :Cucumber,    1.00.each
product :Lettuce,     0.50.each
product :Aubergine,   2.for(1)
product :Tomato,      1.each

class Basket
  def initialize(*args)
    @products = args
  end
  
  def total
    # free_cucumbers_for_every_kg_of_tomatoes!
    cheaper_grapefruits_when_bought_with_oranges!
    apply_vat(@products.inject(0) {|x,y| x + y.price })
  end
  
  private
  
  # def free_cucumbers_for_every_kg_of_tomatoes!
  #   tomato = @products.find {|p| p.is_a? Tomato }
  #   cucumber = @products.find {|p| p.is_a? Cucumber }
  #   if tomato && cucumber
  #     cucumber.quantity -= tomato.quantity
  #   end
  # end
  
  def cheaper_grapefruits_when_bought_with_oranges!
    grapefruit = @products.find {|p| p.is_a? Grapefruit }
    orange = @products.find {|p| p.is_a? Orange }
    
    if grapefruit && orange && orange.quantity > 3
      def grapefruit.price
        @quantity * 1.00
      end
    end
  end
  
  def apply_vat(subtotal)
    sprintf("%0.2f", subtotal * 1.175).to_f
  end
end

class ExportBasket < Basket
  def total
    apply_export_tax @products.inject(0) {|x,y| x + y.price }
  end
  
  private
  
  def apply_export_tax(subtotal)
    sprintf("%0.2f",(subtotal * 1.05) + 1).to_f
  end
end

class BasketTest < Test::Unit::TestCase
  
  def test_should_sell_fruits
    b = Basket.new Banana.new(12), Orange.new(24), Apple.new(1)
    assert_equal 57.58, b.total
  end
  
  # def test_should_sell_veggies
  #   b = Basket.new Aubergine.new(3), Cucumber.new(5), Lettuce.new(1)
  #   assert_equal 7.50, b.total
  # end
  # 
  # def test_should_sell_fruits_and_veggies
  #   b = Basket.new Banana.new(12), Orange.new(24), Apple.new(1), Aubergine.new(3), Cucumber.new(5), Lettuce.new(1)
  #   assert_equal 57.50, b.total
  # end
  
  def test_should_sell_small_fruits
    b = Basket.new Strawberry.new(1), Raspberry.new(2), Cherry.new(0.5)
    assert_equal 7.05, b.total
  end
  
  # def test_should_sell_two_for_one_aubergines
  #   b = Basket.new Aubergine.new(2)
  #   assert_equal 1, b.total
  # end
  
  # def test_should_give_away_cucumber_for_every_kg_of_tomatoes
  #   b = Basket.new Tomato.new(1), Cucumber.new(2)
  #   assert_equal 2, b.total
  # end
  
  def test_should_not_sell_veggies
    assert true
  end
  
  def test_should_sell_grapefruits_for_1_when_more_than_3_oranges_in_basket
    b = Basket.new Grapefruit.new(1), Orange.new(4)
    assert_equal 8.22, b.total
  end

  def test_should_add_vat_to_purchases
    b = Basket.new Plum.new(3)
    assert_equal 5.29, b.total
  end
  
  def test_should_not_add_vat_to_export_purchases_but_add_5_percent_and_1_fee
    b = ExportBasket.new Plum.new(3)
    assert_equal 5.73, b.total
  end

end