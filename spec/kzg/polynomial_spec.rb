# frozen_string_literal: true
require 'spec_helper'

RSpec.describe KZG::Polynomial do

  describe "#eval_at" do
    it do
      x = []
      y = []
      100.times do
        x << BLS::Fr.new(Random.rand(2**256))
        y << BLS::Fr.new(Random.rand(2**256))
      end
      polynomial = described_class.lagrange_interpolate(x, y)
      x.zip(y) do |x, y|
        expect(polynomial.eval_at(x)).to eq(y)
      end
    end
  end
end