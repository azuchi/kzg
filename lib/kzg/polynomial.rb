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

    # Create polynomial using lagrange interpolation using (x, y) list.
    # @param [Array(Integer)] x The array of x coordinate.
    # @param [Array(Integer)] y The array of y coordinate.
    # @return [KZG::Polynomial]
    def self.lagrange_interpolate(x, y)
      n = x.length
      x = x.map { |i| i.is_a?(BLS::Fr) ? i : BLS::Fr.new(i) }
      y = y.map { |i| i.is_a?(BLS::Fr) ? i : BLS::Fr.new(i) }
      coeffs = Array.new(n, BLS::Fr::ZERO)
      n.times do |i|
        prod = BLS::Fr::ONE
        n.times { |j| prod *= (x[i] - x[j]) unless i == j }
        prod = y[i] / prod
        term = [prod] + Array.new(n - 1, BLS::Fr::ZERO)
        n.times do |j|
          next if i == j
          (n - 1).step(1, -1) do |k|
            term[k] += term[k - 1]
            term[k - 1] *= x[j].negate
          end
        end
        n.times { |j| coeffs[j] += term[j] }
      end
      Polynomial.new(coeffs)
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
