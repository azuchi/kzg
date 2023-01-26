# frozen_string_literal: true

module KZG
  # KZG commitment
  class Commitment
    attr_reader :setting, :polynomial, :value

    # Create commitment
    # @param [KZG::Setting] setting
    # @param [Array(Integer | BLS::Fr)] coeffs Coefficients of polynomial equation.
    def initialize(setting, polynomial, value)
      @setting = setting
      @polynomial = polynomial
      @value = value
    end

    # Create commitment using coefficients.
    # @param [KZG::Setting] setting
    # @param [Array(Integer | BLS::Fr)] coeffs Coefficients of polynomial equation.
    def self.from_coeffs(setting, coeffs)
      if coeffs.length > setting.g1_points.length
        raise KZG::Error,
              "coeffs length is greater than the number of secret parameters."
      end
      value =
        coeffs
          .map
          .with_index do |c, i|
            c = c.is_a?(BLS::Fr) ? c : BLS::Fr.new(c)
            c.value.zero? ? BLS::PointG1::ZERO : setting.g1_points[i] * c
          end
          .inject(&:+)
      Commitment.new(setting, KZG::Polynomial.new(coeffs), value)
    end

    # Compute KZG proof for polynomial in coefficient form at position x.
    # @param [Integer] x Position
    # @return [BLS::PointG1] Proof.
    def compute_proof(x)
      divisor = Array.new(2)
      divisor[0] = BLS::Fr.new(x).negate
      divisor[1] = BLS::Fr::ONE
      quotient_poly = polynomial.poly_long_div(divisor)
      Commitment.from_coeffs(setting, quotient_poly).value
    end
  end
end
