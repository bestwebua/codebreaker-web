require 'pry'
require_relative 'session'

module Codebreaker
  class Web
    include Message
    include Motivation
    include Session

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
    def render(template)
      path = File.expand_path("../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def page_not_found
      Rack::Response.new(render('error.html.erb') { message['body']['404_info'] }, 404)
    end

    def load_index
      locale.lang = request.cookies['lang'].to_sym if request.cookies['lang']
      request.session.clear
      Rack::Response.new(render('index.html.erb'))
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
      Rack::Response.new(render('game.html.erb'))
    end

    def show_hint
      Rack::Response.new do |response|
        self.hint = game.hint
        response.redirect('/play')
      end
    end

    def submit_answer
      Rack::Response.new do |response|
        self.last_guess = request.params['number']
        self.marker = game.to_guess(last_guess)
        return response.redirect('finish_game') if game.won? || game.attempts.zero?
        self.hint = false
        response.redirect('/play')
      end
    end

    def finish_game
      ###
    end
  end
end
