# frozen_string_literal: true

require "spec_helper"

RSpec.describe KZG::Commitment do
  let(:setting) do
    secret = 1_927_409_816_240_961_209_460_912_649_124
    KZG.setup_params(secret, 17)
  end

  describe "commit to poly" do
    it do
      coeffs = [1, 2, 3, 4, 7, 7, 7, 7, 13, 13, 13, 13, 13, 13, 13, 13]
      commitment = described_class.from_coeffs(setting, coeffs)
      committed_point = commitment.value
      expect(committed_point.to_hex).to eq(
        "10193d91b11e9cb43cd452fbd0e64dba26307eef309fac038987a0ebe8dd0161502e2b3a449a68869d18d01b537406b51331ab4460884b516d07872612bd629af630244015c2ac68bd542d8fb80b37adef6b956ac233e0aab9cbb893f998a23b"
      )
      proof17 = commitment.compute_proof(17)
      expect(proof17.to_hex).to eq(
        "05a3632d390e34197ce6a037b3b2301c497eaf73e82ff59f39bf85813c49d825e2281771ad206e23a8f4fbc50174f67d06dd6a0407011a1b343d42f839d75348d659382b26de400640d2b6fc155d0edefe69a868e0c87f8ee362e8fde99552cd"
      )
      expect(
        setting.valid_proof?(
          committed_point,
          proof17,
          17,
          39_537_218_396_363_405_614
        )
      ).to be true

      # Specify x = 0
      proof_zro = commitment.compute_proof(0)
      expect(proof_zro.to_hex).to eq(
        "0e89bf7e2ab06734ec3bd4beea82453c58f11bd3ae2e42ffbb88521cc70e0fd300f936225f3b939ba1962f94cd2cd34a08c772b2c31455bb417711f21673fb9a88b723195e7d64b801639b62626919c29c586e3d8c20bedef6de48a13449e3ac"
      )
      expect(
        setting.valid_proof?(
          committed_point,
          proof_zro,
          0,
          commitment.polynomial.eval_at(0)
        )
      ).to be true
      expect(
        setting.valid_proof?(
          committed_point,
          proof17,
          0,
          commitment.polynomial.eval_at(0)
        )
      ).to be false
    end
  end
end
