module Codebreaker
  class GameData
    include Storage

    def initialize(external_path)
      apply_external_path(external_path)
    end
  end
end
