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

  describe "sub" do
    it do
      a_poly =
        described_class.new(10.times.map { BLS::Fr.new(Random.rand(2**256)) })
      b_poly =
        described_class.new(10.times.map { BLS::Fr.new(Random.rand(2**256)) })
      c_poly = a_poly - b_poly
      10.times do |i|
        expect(c_poly.eval_at(i)).to eq(a_poly.eval_at(i) - b_poly.eval_at(i))
      end
    end
  end

  multiply_vector = [
    { p1: [0, 0, 1], p2: [1, 0, 0], result: [0, 0, 1, 0, 0] },
    { p1: [1, 1, 0], p2: [-1, 1, 0], result: [-1, 0, 1, 0, 0] },
    { p1: [0, 0, 3], p2: [2, 0, 0], result: [0, 0, 6, 0, 0] },
    { p1: [1, 2, 3], p2: [-4, 5, -6], result: [-4, -3, -8, 3, -18] }
  ].freeze

  describe "#multiply" do
    it do
      multiply_vector.each do |v|
        p1 = described_class.new(v[:p1])
        p2 = described_class.new(v[:p2])
        expect(p1 * p2).to eq(described_class.new(v[:result]))
      end
    end
  end

  describe "#zero_poly" do
    it do
      x = [1, 2, 3]
      coeffs = described_class.zero_poly(x).coeffs
      expect(coeffs[0]).to eq(BLS::Fr.new(-6))
      expect(coeffs[1]).to eq(BLS::Fr.new(11))
      expect(coeffs[2]).to eq(BLS::Fr.new(-6))
      expect(coeffs[3]).to eq(BLS::Fr::ONE)
    end
  end
end
