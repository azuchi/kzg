# frozen_string_literal: true

require 'bls'
require_relative 'kzg/version'

module KZG

  class Error < StandardError; end

  module_function

  # Setup elements of elliptic curve from +secret+.
  # Note: Since the random secret must not be known to anyone,
  # this Trusted Setup usually needs to be performed using an MPC or similar.
  # @param [Integer] secret random secret.
  # @param [Integer] n number of parameters.
  # @return [Array[Array[BLS::PointG1], Array[BLS::PointG2]]]
  def setup_params(secret, n)
    s1 = Array.new(n)
    s2 = Array.new(n)
    s = BLS::Fq.new(secret)
    s_pow = BLS::Fq::ONE
    n.times do |i|
      s1[i] = BLS::PointG1::BASE * s_pow
      s2[i] = BLS::PointG2::BASE * s_pow
      tmp = s_pow
      s_pow = tmp * s
    end
    [s1, s2]
  end

end
