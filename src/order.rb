require_relative 'formats'
require_relative 'order_item'

class Order
  def initialize(input)
    @items = parse_input(input)
    @breakdown = []
  end

  attr_reader :items

  def parse_input(input)
    items = []
    input.scan(/\d+ \w+/).each do |order|
      begin
        items.push(OrderItem.new(order))
      rescue StandardError
        next
      end
    end
    items
  end

  def print_bundle_breakdown(bundles)
    sum = 0
    bundles.each do |bundle|
      puts "    #{bundle[:amount]} x $#{bundle[:price]}"
      sum += bundle[:amount] * bundle[:price]
    end
    puts "ITEM TOTAL= #{sum}"
  end

  def print_breakdown
    @breakdown.each do |package|
      item = package[:item]
      puts "#{item.quantity} #{item.format.upcase}"
      print_bundle_breakdown(package[:bundles])
    end
  end

  def process
    puts @items
    @items.each do |item|
      @breakdown.push(
        item: item,
        bundles: item.process
      )
    end
  end
end
