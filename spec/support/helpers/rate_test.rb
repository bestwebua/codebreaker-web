module Codebreaker
  class RateTest
    include Rate
    include Storage
    include Utils

    attr_accessor :scores, :token

    def initialize
      expand_score_class
      apply_external_path(File.expand_path("./lib/data"))
      @scores = load_game_data
    end
  end
end
