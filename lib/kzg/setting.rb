# frozen_string_literal: true

module KZG
  #
  class Setting
    attr_reader :g1_points, :g2_points

    # @param [Array(BLS::PointG1)] g1_points
    # @param [Array(BLS::PointG2)] g2_points
    def initialize(g1_points, g2_points)
      raise KZG::Error, "g1_points must be array." unless g1_points.is_a?(Array)
      unless g1_points.all? { |g| g.is_a?(BLS::PointG1) }
        raise KZG::Error, "All elements of g1_points must be BLS::PointG1."
      end
      unless g2_points.all? { |g| g.is_a?(BLS::PointG2) }
        raise KZG::Error, "All elements of g2_points must be BLS::PointG2."
      end

      @g1_points = g1_points
      @g2_points = g2_points
    end

    def ==(other)
      g1_points == other.g1_points && g2_points == other.g2_points
    end

    # Check a proof for a KZG commitment for an evaluation f(x) = y
    # @param [BLS::PointG1] commit_point
    # @param [BLS::PointG1] proof
    # @param [Integer|BLS::Fr] x
    # @param [Integer|BLS::Fr] y
    def valid_proof?(commit_point, proof, x, y)
      x = x.is_a?(BLS::Fr) ? x : BLS::Fr.new(x)
      y = y.is_a?(BLS::Fr) ? y : BLS::Fr.new(y)
      xg2 = x.value.zero? ? BLS::PointG2::ZERO : BLS::PointG2::BASE * x
      yg = y.value.zero? ? BLS::PointG1::ZERO : BLS::PointG1::BASE * y

      # e([commitment - y]^(-1), [1]) * e([proof],  [s - x]) = 1
      lhs =
        BLS.pairing(
          (commit_point - yg).negate,
          BLS::PointG2::BASE,
          with_final_exp: false
        )
      rhs = BLS.pairing(proof, g2_points[1] - xg2, with_final_exp: false)
      exp = (lhs * rhs).final_exponentiate
      exp == BLS::Fp12::ONE
    end

    # Check a proof for a KZG commitment for an evaluation f(x) = y
    # @param [BLS::PointG1] commit_point
    # @param [BLS::PointG1] proof
    # @param [Array(Integer|BLS::Fr)] x
    # @param [Array(Integer|BLS::Fr)] y
    def valid_multi_proof?(commit_point, proof, x, y)
      x = x.map { |v| v.is_a?(BLS::Fr) ? v.value : v }
      y = y.map { |v| v.is_a?(BLS::Fr) ? v.value : v }
      # compute i(x)
      i_poly = Polynomial.lagrange_interpolate(x, y)
      # compute z(x)
      z_poly = Polynomial.zero_poly(x)
      # e([commitment - interpolation_polynomial(s)]^(-1), [1]) * e([proof],  [s^n - x^n]) = 1
      is = Commitment.new(self, i_poly).value
      lhs =
        BLS.pairing(
          (commit_point - is).negate,
          BLS::PointG2::BASE,
          with_final_exp: false
        )
      z_commit =
        z_poly
          .coeffs
          .map
          .with_index do |c, i|
            c.value.zero? ? BLS::PointG2::ZERO : g2_points[i] * c
          end
          .inject(&:+)
      rhs = BLS.pairing(proof, z_commit, with_final_exp: false)
      exp = (lhs * rhs).final_exponentiate
      exp == BLS::Fp12::ONE
    end
  end
end
