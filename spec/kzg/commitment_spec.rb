# frozen_string_literal: true

require "spec_helper"

RSpec.describe KZG::Commitment do
  let(:setting) do
    secret = 1_927_409_816_240_961_209_460_912_649_124
    KZG.setup_params(secret, 17)
  end
  let(:commitment) do
    coeffs = [1, 2, 3, 4, 7, 7, 7, 7, 13, 13, 13, 13, 13, 13, 13, 13]
    described_class.from_coeffs(setting, coeffs)
  end

  describe "commit to poly" do
    it do
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

  describe "single point test" do
    it do
      max_degree_poly = BLS::Curve::R - 1
      n = 32
      coeffs = n.times.map { Random.rand(1..max_degree_poly) }
      setting = KZG.setup_params(Random.rand(1..2**256), n)
      commitment = described_class.from_coeffs(setting, coeffs)
      Parallel.each(n.times) do |i|
        proof = commitment.compute_proof(i)
        value = commitment.polynomial.eval_at(i)
        expect(
          setting.valid_proof?(commitment.value, proof, i, value)
        ).to be true
      end
    end
  end

  describe "multiple proof" do
    it do
      x = [
        5431,
        4_499_528_929_364_396_752_083_214_081_832_576_393_571_841_586_696_434_084_581_779_033_382_745_709_474,
        18_819_201_550_406_005_743_273_919_821_165_131_028_785_741_157_864_680_821_096_448,
        29_920_647_712_455_020_818_378_537_079_698_978_519_954_283_129_595_295_864_142_917_432_089_396_903_007,
        52_435_875_175_126_190_479_447_740_508_185_965_837_690_552_500_527_637_822_603_658_699_938_581_179_082,
        47_936_346_245_761_793_727_364_526_426_353_389_444_118_710_913_831_203_738_021_879_666_555_835_475_039,
        52_435_875_175_126_171_660_246_190_102_180_222_563_770_731_335_396_609_036_862_500_835_257_760_088_065,
        22_515_227_462_671_169_661_069_203_428_486_987_317_736_269_370_932_341_958_460_741_267_849_184_281_506
      ]
      multi_proof = commitment.compute_multi_proof(x)
      expect(multi_proof.to_hex).to eq(
        "18f651a90e8292567bfe792dbaa0c96909704288597712309188a5050f17abd90006e53a5b2bbe9d5f6b5517c723b706041ee0de2c3c4f209f6ef5fd578a6ee852028e942cb2a49f594159b2facb46b943e4276c9679315ca249eeb3804c01bd"
      )
    end
  end
end
