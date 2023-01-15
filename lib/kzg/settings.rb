# frozen_string_literal: true

module KZG
  # 
  class Settings

    attr_reader :g1_points, :g2_points

    # @param [Array[BLS::PointG1]] g1s
    # @param [Array[BLS::PointG2]] g2s
    def initialize(g1_points, g2_points)
      raise KZG::Error, 'g1_points and g2_points must be array.' if !g1_points.is_a?(Array) || !g2_points.is_a?(Array)
      raise KZG::Error, 'All elements of g1_points must be BLS::PointG1.' unless g1_points.all? { |g| g.is_a?(BLS::PointG1) }
      raise KZG::Error, 'All elements of g2_points must be BLS::PointG2.' unless g2_points.all? { |g| g.is_a?(BLS::PointG2) }

      @g1_points = g1_points
      @g2_points = g2_points
    end

    # Generate polynomial commitment.
    # @param [Array[Integer]] Coefficients of a polynomial.
    # @return [BLS::PointG1]
    def commit_to_poly(coeffs)
      raise KZG::Error, 'coeffs length is greater than the number of secret parameters.' if coeffs.length > g1_points.length

      coeffs.map.with_index { |c, i| g1_points[i] * BLS::Fq.new(c) }.inject(&:+)
    end

    # Compute KZG proof for polynomial in coefficient form at position +x+.
    # @param [Array[Integer]] Coefficients of a polynomial.
    # @param [Integer] x position
    # @return [BLS::PointG1] proof
    def compute_proof(coeffs, x)
      divisor = Array.new(2)
      tmp = BLS::Fq.new(x)
      divisor[0] = BLS::Fq::ZERO - tmp
      divisor[1] = BLS::Fq::ONE
      quotient_poly = poly_long_div(coeffs, divisor)
      quotient_poly.map.with_index { |c, i| g1_points[i] * c }.inject(&:+)
    end

    def ==(other)
      g1_points == other.g1_points && g2_points == other.g2_points
    end

    def valid_proof?(commitment, proof, x, value)

    end

    private

    def poly_long_div(coeffs, divisor)
      a = coeffs.map { |c| BLS::Fq.new(c) }
      a_pos = a.length - 1
      b_pos = divisor.length - 1
      diff = a_pos - b_pos
      quotient_poly = []
      while diff >= 0
        quot = a[a_pos] / divisor[b_pos]
        i = b_pos
        while i >= 0
          tmp = quot * divisor[i]
          tmp2 = a[diff + i] * tmp
          a[diff + 1] = tmp2
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
