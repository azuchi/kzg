# frozen_string_literal: true

module KZG
  # 
  class Setting

    attr_reader :g1_points, :g2_points

    # @param [Array[BLS::PointG1]] g1s
    # @param [Array[BLS::PointG2]] g2s
    def initialize(g1_points, g2_points)
      raise KZG::Error, 'g1_points and g2_points must be array.' if !g1_points.is_a?(Array) || !g2_points.is_a?(Array)
      raise KZG::Error, 'All elements of g1_points must be BLS::PointG1.' unless g1_points.all? { |g| g.is_a?(BLS::PointG1) }
      raise KZG::Error, 'All elements of g2_points must be BLS::PointG2.' unless g2_points.all? { |g| g.is_a?(BLS::PointG2) }

      @g1_points = g1_points
      @g2_points = g2_points
    end

    def ==(other)
      g1_points == other.g1_points && g2_points == other.g2_points
    end

    def valid_proof?(commitment, proof, x, value)

    end
  end
end
