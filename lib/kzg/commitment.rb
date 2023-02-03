# frozen_string_literal: true

module KZG
  # KZG commitment
  class Commitment
    attr_reader :setting, :polynomial, :value

    # Create commitment
    # @param [KZG::Setting] setting
    # @param [KZG::Polynomial] polynomial
    def initialize(setting, polynomial)
      @setting = setting
      @polynomial = polynomial
      @value =
        polynomial
          .coeffs
          .map
          .with_index do |c, i|
            c = c.is_a?(BLS::Fr) ? c : BLS::Fr.new(c)
            c.value.zero? ? BLS::PointG1::ZERO : setting.g1_points[i] * c
          end
          .inject(&:+)
    end

    # Create commitment using coefficients.
    # @param [KZG::Setting] setting
    # @param [Array(Integer | BLS::Fr)] coeffs Coefficients of polynomial equation.
    def self.from_coeffs(setting, coeffs)
      if coeffs.length > setting.g1_points.length
        raise KZG::Error,
              "coeffs length is greater than the number of secret parameters."
      end
      Commitment.new(setting, KZG::Polynomial.new(coeffs))
    end

    # Compute KZG proof for polynomial in coefficient form at position x.
    # @param [Integer] x Position
    # @return [BLS::PointG1] Proof.
    def compute_proof(x)
      divisor = Polynomial.new([BLS::Fr.new(x).negate, BLS::Fr::ONE])
      quotient_poly = polynomial / divisor
      Commitment.from_coeffs(setting, quotient_poly.coeffs).value
    end

    # Compute KZG multi proof using list of x coordinate.
    # @param [Array(Integer)] x An array of x coordinate.
    # @return [BLS::PointG1]
    def compute_multi_proof(x)
      y = x.map { |i| polynomial.eval_at(i) }
      # compute i(x)
      i_poly = Polynomial.lagrange_interpolate(x, y)
      # compute z(x)
      z_poly = Polynomial.zero_poly(x)
      # compute q(x) = (p(x) - i(x)) / z(x)
      quotient_poly = (polynomial - i_poly) / z_poly
      Commitment.from_coeffs(setting, quotient_poly.coeffs).value
    end
  end
end
