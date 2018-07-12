module Codebreaker
  module Rate
    private

    def rate(type, key)
      range = 0..Float::INFINITY
      winners_table = [true, false].zip(range)
      levels_table = [Game::HARD_LEVEL, Game::MIDDLE_LEVEL, Game::SIMPLE_LEVEL].zip(range)
      %i[winner level].zip([winners_table, levels_table].map(&:to_h)).to_h[type][key]
    end

    def top_players
      scores.sort_by do |player_score|
        by_winner = rate(:winner, player_score.winner)
        by_level = rate(:level, player_score.level)
        by_score = -player_score.score

        if player_score.score.negative?
          [by_score]
        else
          [by_winner, by_level, by_score]
        end
      end
    end

    def player_rate(player_token = self.token)
      top_players.index { |player_score| player_score.token == player_token }&.next
    end
  end
end
