require 'pry'
require_relative 'utils'

module Codebreaker
  class Web
    include Message
    include Motivation
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
      define_session_accessors
      apply_external_path(File.expand_path("./lib/data"))
    end

    def response
      case request.path
        when '/' then load_index
        when '/change_lang' then change_lang
        when '/play' then play
        when '/show_hint' then show_hint
        when '/submit_answer' then submit_answer
        when '/finish_game', '/scores' then finish_game
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

    def play
      self.game ||= Game.new do |config|
        config.player_name = request.params['player_name']
        config.max_attempts = 5
        config.max_hints = 2
        config.level = request.params['level'].to_sym
        config.lang = self.locale.lang
      end

      if game_over?
        go_to('/finish_game')
      else
        scores || load_scores
        template('game')
      end
    end

    def show_hint #should be a restricted access
      self.hint = game.hint if hints_allowed?
      go_to('/play')
    end

    def submit_answer
      user_input = request.params['number']

      begin
        game.guess_valid?(user_input)
        self.last_guess = user_input
      rescue
        go_to('/play')
      end
      
      self.marker = game.to_guess(last_guess).tr(' ','x')

      if game_over?
        save_game_data
        go_to('/finish_game')
      else
        self.hint = false
        go_to('/play')
      end
    end

    def finish_game #should be a restricted access
      load_scores
      template('score')
      #request.session.clear
    end
  end
end
