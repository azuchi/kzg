# frozen_string_literal: true

RSpec.describe KZG do
  describe "#setup" do
    it do
      secret = 11
      n = 16
      setup1 = KZG.setup_params(secret, n)
      setup2 = KZG.setup_params(secret, n)
      expect(setup1).to eq(setup2)
      expect(setup1.g1s.length).to eq(n)
    end
  end
end
