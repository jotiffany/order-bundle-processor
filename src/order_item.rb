require_relative 'formats'

class OrderItem
  def initialize(input)
    props = input.match(/(?<quantity>\d+) (?<format>\w+)/)

    raise StandardError, 'Invalid input' unless props

    @quantity = Integer(props[:quantity])
    @format = props[:format].downcase
    raise StandardError, 'Invalid format' unless FORMATS[@format]

    @bundles = FORMATS[@format]
  end

  attr_reader :quantity

  attr_reader :format

  attr_reader :bundles

  def to_s
    "#{@quantity} #{format.upcase}"
  end

  def process
    return [] unless @bundles
    return [] if @quantity < @bundles.keys.min

    select_best_match(matches)
  end

  def matches
    matches = []
    @bundles.keys.each do |bdl_qty|
      match = find_matches(
        bdl_qty,
        @quantity / bdl_qty,
        @quantity % bdl_qty
      )
      matches.push(match) if match
    end
    matches
  end

  def find_matches(bdl_qty, amount, remainder, selected = [])
    selected.push(
      bdl_qty: bdl_qty,
      amount: amount,
      price: @bundles[bdl_qty]
    )
    return selected if remainder < @bundles.keys.min

    @bundles.keys.each do |qty|
      amount = remainder / qty
      remainder = remainder % qty
      selected.push(
        bdl_qty: qty,
        amount: amount,
        price: @bundles[qty]
      )

      return selected if remainder < @bundles.keys.min

      return find_matches(qty, amount, remainder, selected)
    end
  end

  def select_best_match(matches)
    best = nil
    matches.each do |match|
      match_total = 0
      match_qty = 0
      match.each do |bundle|
        match_total += bundle[:bdl_qty] * bundle[:amount]
        match_qty += bundle[:amount]
      end

      best ||= {
        match: match,
        total: match_total,
        quantity: match_qty
      }

      exact_match = (match_total == @quantity)
      less_bundle_count = (best[:total] != @quantity) &&
                          (match_qty < best[:quantity])
      next unless exact_match || less_bundle_count

      best = {
        match: match,
        total: match_total,
        quantity: match_qty
      }
    end
    best[:match]
  end
end
