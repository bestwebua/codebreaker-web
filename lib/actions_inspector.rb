require_relative 'urls'
require_relative 'utils'

module Codebreaker
  class ActionsInspector
    include Urls
    include Message
    include Utils

    attr_reader :request, :locale, :restricted_access, :player_name, :level

    def initialize(app)
      @app = app
      @restricted_access = [HINT_URL, SUBMIT_URL, FINISH_URL]
    end

    def call(env)
      @request = Rack::Request.new(env)
      @locale = request.session.options[:locale]      
      @player_name = request.params['player_name']
      @level = request.params['level']

      if forbidden?
        error_template('error', 403) { message['body']['403_info'] }
      else
        status, headers, response = @app.call(env)
        Rack::Response.new(response, status, headers)
      end
    end

    private

    def forbidden?
      case
        when restricted_access.include?(request.path)
          session_failed?
        when request.path == PLAY_URL
          (anonymous? || fake_data?) && session_failed?
        when request.path == LANG_URL
          fake_lang?
        else false
      end
    end

    def session_failed?
      !request.session[:game]
    end

    def anonymous?
      !player_name || !level
    end

    def fake_data?
      levels = [Game::SIMPLE_LEVEL, Game::MIDDLE_LEVEL, Game::HARD_LEVEL]
      !player_name[/\A[\w\u0400-\u04ff]{3,20}\z/] || !levels.include?(level.to_sym)
    end

    def fake_lang?
      !locale.all.include?(request.params['lang']&.to_sym)
    end
  end
end
