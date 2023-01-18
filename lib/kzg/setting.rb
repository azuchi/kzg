# frozen_string_literal: true

module KZG
  #
  class Setting
    attr_reader :g1_points, :g2_points

    # @param [Array[BLS::PointG1]] g1s
    # @param [Array[BLS::PointG2]] g2s
    def initialize(g1_points, g2_points)
      if !g1_points.is_a?(Array) || !g2_points.is_a?(Array)
        raise KZG::Error, "g1_points and g2_points must be array."
      end
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
      xg2 = BLS::PointG2::BASE * x
      yg = BLS::PointG1::BASE * y

      # e([commitment - y]^(-1), [1]) * e([proof],  [s - x]) = 1
      lhs =
        BLS.pairing(
          (commit_point - yg).negate,
          BLS::PointG2::BASE,
          with_final_exp: false
        )
      rhs = BLS.pairing(proof, g2_points[1] - xg2, with_final_exp: false)
      exp = (lhs * rhs).final_exponentiate
      exp == BLS::Fq12::ONE
    end
  end
end
