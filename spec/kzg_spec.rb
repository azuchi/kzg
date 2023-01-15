# frozen_string_literal: true

RSpec.describe KZG do
  describe "#setup" do
    it do
      secret = 11
      degree = 16
      setup1 = KZG.setup_params(secret, degree)
      setup2 = KZG.setup_params(secret, degree)
      expect(setup1).to eq(setup2)
    end
  end
end
