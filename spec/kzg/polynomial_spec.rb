# frozen_string_literal: true
require "spec_helper"

RSpec.describe KZG::Polynomial do
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
end
