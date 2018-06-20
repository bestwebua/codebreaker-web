require 'pry'
require_relative 'utils'

module Codebreaker
  class Web
    include Message
    include Motivation
    include Utils

    def self.call(env)
      new(env).response.finish
    end

    attr_reader :request, :locale

    def initialize(env)
      @request = Rack::Request.new(env)
      @locale = request.session.options[:locale]
      define_session_accessors
    end

    def response
      case request.path
        when '/'              then load_index
        when '/change_lang'   then change_lang
        when '/play'          then play
        when '/show_hint'     then show_hint
        when '/submit_answer' then submit_answer
        when '/finish_game'   then finish_game
        else page_not_found
      end
    end

    private
    def page_not_found
      error_template('error', 404) { message['body']['404_info'] }
    end

    def load_index
      locale.lang = request.cookies['lang'].to_sym if request.cookies['lang']
      request.session.clear
      template('index')
    end

    def change_lang
      Rack::Response.new do |response|
        response.set_cookie('lang', request.params['lang'])
        response.redirect('/')
      end
    end

    def play
      self.game ||= Game.new do |config|
        config.player_name = request.params['player_name']
        config.max_attempts = 5
        config.max_hints = 2
        config.level = request.params['level'].to_sym
        config.lang = self.locale.lang
      end
      template('game')
    end

    def show_hint
      self.hint = game.hint
      go_to('/play')
    end

    def game_over?
      game.won? || game.attempts.zero?
    end

    def submit_answer
      self.last_guess = request.params['number']
      self.marker = game.to_guess(last_guess)
      if game_over?
        go_to('/finish_game')
      else
        self.hint = false
        go_to('/play')
      end
    end

    def finish_game
      template('score')
    end
  end
end
