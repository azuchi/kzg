# frozen_string_literal: true
require "spec_helper"

RSpec.describe KZG::Polynomial do
  let(:setting) do
    secret = Random.rand(2**256)
    KZG.setup_params(secret, 11)
  end

  describe "#eval_at" do
    it do
      x_coordinates = []
      y_coordinates = []
      100.times do
        x_coordinates << BLS::Fr.new(Random.rand(2**256))
        y_coordinates << BLS::Fr.new(Random.rand(2**256))
      end
      polynomial =
        described_class.lagrange_interpolate(x_coordinates, y_coordinates)
      x_coordinates.zip(y_coordinates) do |x, y|
        evaluated = polynomial.eval_at(x)
        expect(evaluated).to eq(y)
        expect(evaluated).not_to eq(y + BLS::Fr::ONE)
      end
    end
  end

  describe "#add" do
    it do
      a_poly =
        described_class.new(10.times.map { BLS::Fr.new(Random.rand(2**256)) })
      b_poly =
        described_class.new(11.times.map { BLS::Fr.new(Random.rand(2**256)) })
      c_poly = a_poly + b_poly
      c_poly
        .coeffs
        .zip(a_poly.coeffs, b_poly.coeffs) do |c, a, b|
          target = b
          target += a if a
          expect(c).to eq(target)
        end
      10.times do |i|
        expect(c_poly.eval_at(i)).to eq(a_poly.eval_at(i) + b_poly.eval_at(i))
      end
      # Sum of commitment value also same
      a_commitment = KZG::Commitment.from_coeffs(setting, a_poly.coeffs)
      b_commitment = KZG::Commitment.from_coeffs(setting, b_poly.coeffs)
      c_commitment = KZG::Commitment.from_coeffs(setting, c_poly.coeffs)
      expect(c_commitment.value).to eq(a_commitment.value + b_commitment.value)
    end
  end
end
