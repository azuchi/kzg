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

    # Create polynomial from array of x coordinate like f(x) = (x - x0)(x - x1)...(x - xn)
    # @param [Array(Integer)] x An array of x coordinate.
    # @return [KZG::Polynomial]
    def self.zero_poly(x)
      poleis =
        x.map { |v| Polynomial.new([BLS::Fr.new(v).negate, BLS::Fr::ONE]) }
      poleis[1..].inject(poleis.first) { |result, poly| result * poly }
    end

    # Evaluate polynomial for given +x+ using Horner's method.
    # @param [Integer | BLS::Fr] x
    # @return [BLS::Fr] Evaluated value.
    def eval_at(x)
      x = x.is_a?(BLS::Fr) ? x : BLS::Fr.new(x)
      return BLS::Fr::ZERO if coeffs.empty?
      return coeffs.first if x.value.zero?
      last = coeffs[coeffs.length - 1]
      (coeffs.length - 2).step(0, -1) do |i|
        tmp = last * x
        last = tmp + coeffs[i]
      end
      last
    end

    # Returns a new polynomial that is the sum of the given polynomial and this polynomial.
    # @param [KZG::Polynomial] other
    # @return [KZG::Polynomial] Sum of polynomial.
    def add(other)
      base, target =
        if coeffs.length < other.coeffs.length
          [other.coeffs, coeffs]
        else
          [coeffs, other.coeffs]
        end
      sum = base.zip(target).map { |a, b| b.nil? ? a : a + b }
      Polynomial.new(sum)
    end
    alias + add

    # Return a new polynomial that multiply self and the given polynomial.
    # @param [KZG::Polynomial] other Other polynomial
    # @return [KZG::Polynomial] Multiplied polynomial
    # @return ArgumentError
    def multiply(other)
      unless other.is_a?(Polynomial)
        raise ArgumentError, "multiply target must be Polynomial"
      end
      new_coeffs = Array.new(coeffs.length + other.coeffs.length - 1)
      coeffs.each.with_index do |a, i|
        other.coeffs.each.with_index do |b, j|
          k = i + j
          new_coeffs[k] = a * b + (new_coeffs[k] || BLS::Fr::ZERO)
        end
      end
      Polynomial.new(new_coeffs)
    end
    alias * multiply

    def ==(other)
      return false unless other.is_a?(Polynomial)
      coeffs == other.coeffs
    end

    # Long polynomial division for two polynomials in coefficient form
    # @param [Array(BLS::Fr)] divisor Array of divisor.
    # @return [Array(BLS::Fr)]
    def poly_long_div(divisor)
      a = coeffs.dup
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
