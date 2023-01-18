# frozen_string_literal: true

module KZG
  # Polynomial
  class Polynomial
    attr_reader :coeffs

    # Create new polynomial
    # @param [Array(Integer|BLS::Fr)]
    def initialize(coeffs)
      @coeffs = coeffs.map { |c| c.is_a?(BLS::Fr) ? c : BLS::Fr.new(c) }
    end

    # Evaluates a polynomial expression with the specified value +x+.
    # @param [Integer|BLS::Fr] x
    # @return [BLS::Fr]
    def eval_at(x)
      power = x.is_a?(BLS::Fr) ? x : BLS::Fr.new(x)
      sum = coeffs.first
      coeffs[1..].each do |c|
        sum += c * power
        power *= power
      end
      sum
    end

    # Long polynomial division for two polynomials in coefficient form
    # @param [Array(BLS::Fr)] divisor Array of divisor.
    # @return [Array(BLS::Fr)]
    def poly_long_div(divisor)
      a = coeffs
      a_pos = a.length - 1
      b_pos = divisor.length - 1
      diff = a_pos - b_pos
      quotient_poly = []

      while diff >= 0
        quot = a[a_pos] / divisor[b_pos]
        i = b_pos
        while i >= 0
          tmp = quot * divisor[i]
          tmp2 = a[diff + i] - tmp
          a[diff + i] = tmp2
          i -= 1
        end
        quotient_poly[diff] = quot
        a_pos -= 1
        diff -= 1
      end
      quotient_poly
    end
  end
end
