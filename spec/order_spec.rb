require 'rspec'
require 'rspec/autorun'
require_relative '../src/order'

RSpec.describe Order do
  it 'should parse input into a list of items' do
    order = Order.new('10 IMG 15 FLAC')
    expect(order.items.size).to eq 2
    expect(order.items.first.quantity).to eq 10
    expect(order.items.first.format).to eq 'img'
    expect(order.items.last.quantity).to eq 15
    expect(order.items.last.format).to eq 'flac'
  end

  it 'should process multiple items in one order' do
    order = Order.new('10 IMG 15 FLAC 13 VID')
    breakdown = order.process
    expect(breakdown.size).to eq 3
  end

  it 'should ignore items with invalid formats' do
    order = Order.new('10 MP4')
    breakdown = order.process
    expect(breakdown.size).to eq 0
  end

  it 'should print breakdown' do
    order = Order.new('10 IMG 15 FLAC 13 VID')
    order.process
    order.print_breakdown
  end
end
