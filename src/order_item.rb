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

    find_exact_smallest_bundle(matches).map do |quantity, amount|
      { bdl_qty: quantity, amount: amount, price: amount * @bundles[quantity] }
    end
  end

  def matches
    combos = []
    # get all possible combinations of numbers to get target
    @bundles.keys.each do |num|
      partials = {}
      partials[num] = @quantity / num
      # stop if exact match to the target quantity already
      if (@quantity % num).zero?
        combos.push(compute_combo_info(partials))
        next
      end

      partials = process_subset(
        @bundles.keys - partials.keys, @quantity, partials
      )
      combos.push(compute_combo_info(partials))
    end
    combos
  end

  def compute_combo_info(partials)
    {
      bundles: partials,
      sum: multiplier_sum(partials),
      bundle_count: partials.values.reduce(0, :+)
    }
  end

  def process_subset(numbers, target, partials = {})
    return partials if numbers.empty?

    sum = multiplier_sum(partials)
    return partials if sum >= target

    difference = target - sum
    return partials if difference < numbers.min

    numbers.each do |num|
      partials[num] = difference / num
      return process_subset(
        numbers - partials.keys, target, partials
      )
    end
  end

  def multiplier_sum(values)
    sum = 0
    values.each do |quantity, multiplier|
      sum += (quantity * multiplier)
    end
    sum
  end

  def find_exact_smallest_bundle(combos)
    combos.sort_by! { |c| c[:bundle_count] }
    # prioritize exact matches with the smallest bundle count
    best = combos
           .select { |c| c[:sum] == @quantity }
           .first
    best ||= combos.first
    best[:bundles]
  end
end
