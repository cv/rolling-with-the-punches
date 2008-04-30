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
product :Strawberry,  1.00.per_kilo
product :Cherry,      2.00.per_kilo
product :Raspberry,   2.00.per_kilo
product :Blackberry,  2.00.per_kilo
product :Cranberry,   2.00.per_kilo
product :Plum,        1.50.each
product :Grapefruit,  1.00.each

class Basket
  def initialize(*args)
    @products = args
  end
  
  def total
    cheaper_grapefruits_when_bought_with_oranges!
    @products.inject(0) {|x,y| x + y.price }
  end
  
  private
  
  def cheaper_grapefruits_when_bought_with_oranges!
    grapefruit = @products.find {|p| p.is_a? Grapefruit }
    orange = @products.find {|p| p.is_a? Orange }
    
    if grapefruit && orange && orange.quantity > 3
      def grapefruit.price
        @quantity * 1.00
      end
    end
  end
  
end

class BasketTest < Test::Unit::TestCase
  
  def test_should_sell_fruits
    b = Basket.new Banana.new(12), Orange.new(24), Apple.new(1)
    assert_equal 49.00, b.total
  end
  
  def test_should_sell_small_fruits
    b = Basket.new Strawberry.new(1), Raspberry.new(2), Cherry.new(0.5)
    assert_equal 6.00, b.total
  end
  
  def test_should_not_sell_veggies
    assert true
  end
  
  def test_should_sell_grapefruits_for_1_when_more_than_3_oranges_in_basket
    b = Basket.new Grapefruit.new(1), Orange.new(4)
    assert_equal 7.00, b.total
  end
  
  
  
end
