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
product :Apple,       2.00.each
product :Orange,      1.50.each

product :Cucumber,    1.00.each
product :Lettuce,     0.50.each
product :Aubergine,   1.50.each

class Basket
  def initialize(*args)
    @products = args
  end
  
  def total
    @products.inject(0) {|x,y| x + y.price }
  end
end

class BasketTest < Test::Unit::TestCase
  
  def test_should_sell_fruits
    b = Basket.new Banana.new(12), Orange.new(24), Apple.new(1)
    assert_equal 50.00, b.total
  end
  
  def test_should_sell_veggies
    b = Basket.new Aubergine.new(3), Cucumber.new(5), Lettuce.new(1)
    assert_equal 10.00, b.total
  end

  def test_should_sell_fruits_and_veggies
    b = Basket.new Banana.new(12), Orange.new(24), Apple.new(1), Aubergine.new(3), Cucumber.new(5), Lettuce.new(1)
    assert_equal 60.00, b.total
  end

end
