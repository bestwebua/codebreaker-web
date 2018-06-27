module Codebreaker
  module Urls
    ROOT_URL   = '/'
    LANG_URL   = '/change_lang'
    PLAY_URL   = '/play'
    HINT_URL   = '/show_hint'
    SUBMIT_URL = '/submit_answer'
    FINISH_URL = '/finish_game'
    SCORES_URL = '/top_scores'
  end

  module WebGameConfig
    MAX_ATTEMPTS = 5
    MAX_HINTS = 2
  end
end
