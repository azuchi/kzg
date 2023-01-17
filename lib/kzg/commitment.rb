module KZG
  class Commitment

    attr_reader :setting, :polynomial, :value

    # Create commitment
    # @param [KZG::Setting] setting
    # @param [Array(Integer | BLS::Fr)] params Parameters to commit.
    def initialize(setting, params)
      raise KZG::Error, 'coeffs length is greater than the number of secret parameters.' if params.length > setting.g1_points.length
      @setting = setting
      @polynomial = KZG::Polynomial.new(params)

      @value = params.map.with_index { |c, i| setting.g1_points[i] * (c.is_a?(BLS::Fr) ? c : BLS::Fr.new(c)) }.inject(&:+)
    end

    # Compute KZG proof for polynomial in coefficient form at position x.
    # @param [Integer] x Position
    # @return [BLS::PointG1] Proof.
    def compute_proof(x)
      divisor = Array.new(2)
      divisor[0] = BLS::Fr.new(x).negate
      divisor[1] = BLS::Fr::ONE
      quotient_poly = polynomial.poly_long_div(divisor)
      Commitment.new(setting, quotient_poly).value
    end

  end
end