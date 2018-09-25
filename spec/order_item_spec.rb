require 'rspec'
require 'rspec/autorun'
require_relative '../src/order_item'

RSpec.describe OrderItem do
  it 'should parse input into quantity and format' do
    item = OrderItem.new('10 IMG')
    expect(item.quantity).to eq 10
    expect(item.format).to eq 'img'
  end

  it 'should ignore malformed input' do
    expect do
      OrderItem.new('abc 123')
    end.to raise_error(
      StandardError,
      'Invalid input'
    )
  end

  it 'should match with a combo with no remainder' do
    order = OrderItem.new('10 IMG')
    bundles = order.process
    expect(bundles.size).to eq 1
    expect(bundles.first[:bdl_qty]).to eq 10
    expect(bundles.first[:amount]).to eq 1
  end

  it 'should return no bundles if quantity is too small' do
    order = OrderItem.new('3 IMG')
    bundles = order.process
    expect(bundles).to eq []
  end

  it 'should match with a combo even with a remainder' do
    order = OrderItem.new('16 IMG')
    bundles = order.process
    expect(bundles.size).to eq 2
    expect(bundles.first[:bdl_qty]).to eq 10
    expect(bundles.first[:amount]).to eq 1
    expect(bundles.last[:bdl_qty]).to eq 5
    expect(bundles.last[:amount]).to eq 1
  end

  it 'should select the best match with no remainder' do
    order = OrderItem.new('13 VID')
    bundles = order.process
    expect(bundles.size).to eq 2
    expect(bundles.first[:bdl_qty]).to eq 5
    expect(bundles.first[:amount]).to eq 2
    expect(bundles.last[:bdl_qty]).to eq 3
    expect(bundles.last[:amount]).to eq 1
  end

  it 'should select the combo with the least amount of bundles' do
    order = OrderItem.new('27 VID')
    bundles = order.process
    expect(bundles.size).to eq 1
    expect(bundles.first[:bdl_qty]).to eq 9
    expect(bundles.first[:amount]).to eq 3
  end

  it 'should not proceed if there are no bundles' do
    expect do
      OrderItem.new('10 MP4')
    end.to raise_error(
      StandardError,
      'Invalid format'
    )
  end
end
