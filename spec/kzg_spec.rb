# frozen_string_literal: true

RSpec.describe KZG do
  describe "#setup" do
    it do
      secret = 11
      n = 3
      setup1 = described_class.setup_params(secret, n)
      setup2 = described_class.setup_params(secret, n)
      expect(setup1).to eq(setup2)
      expect(setup1.g1_points.length).to eq(n)
    end
  end
end
