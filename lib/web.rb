require_relative 'consts'
require_relative 'utils'

module Codebreaker
  class Web
    include Urls
    include Message
    include Motivation
    include WebGameConfig
    include TemplatesConst
    include Utils
    include UserScore
    include Storage

    def self.call(env)
      new(env).response.finish
    end

    attr_reader :request, :locale

    def initialize(env)
      @request = Rack::Request.new(env)
      @locale = request.session.options[:locale]
      expand_score_class
      define_session_accessors
      apply_external_path(File.expand_path("./lib/data"))
    end

    def response
      case request.path
        when ROOT_URL then load_index
        when LANG_URL then change_lang
        when PLAY_URL then play
        when HINT_URL then show_hint
        when SUBMIT_URL then submit_answer
        when FINISH_URL then finish_game
        when SCORES_URL then top_scores
        else page_not_found
      end
    end

    private

    def page_not_found
      error_template('error', 404) { message['body']['404_info'] }
    end

    def load_index
      request.session.clear
      template('index')
    end

    def change_lang
      lang_choice = request.params['lang']
      locale.lang = lang_choice.to_sym if lang_choice
      go_to(referer)
    end

    def play #should have a restricted access
      create_game_instance
      generate_token
      set_client_ip

      if game_over?
        go_to(FINISH_URL)
      else
        scores || load_scores
        template('game')
      end
    end

    def show_hint #should have a restricted access
      self.hint = game.hint if hints_allowed?
      go_to(PLAY_URL)
    end

    def submit_answer
      user_input = request.params['number']

      begin
        game.guess_valid?(user_input)
        self.last_guess = user_input
      rescue
        go_to(PLAY_URL)
      end

      self.marker = game.to_guess(last_guess).tr(' ','x')

      if game_over?
        save_game_data
        go_to(FINISH_URL)
      else
        self.hint = false
        go_to(PLAY_URL)
      end
    end

    def finish_game #should have a restricted access
      template('scores')
    end

    def top_scores
      request.session.clear
      load_scores
      template('scores')
    end
  end
end
