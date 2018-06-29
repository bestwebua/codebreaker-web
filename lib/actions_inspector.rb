require_relative 'utils'
require_relative 'consts'

module Codebreaker
  class ActionsInspector
    include Urls
    include Message
    include Utils

    attr_reader :request, :locale, :restricted_access

    def initialize(app)
      @app = app
    end

    def call(env)
      @request = Rack::Request.new(env)
      @locale = request.session.options[:locale]
      @restricted_access = [HINT_URL, SUBMIT_URL, FINISH_URL]

      if forbidden?
        error_template('error', 403) { message['body']['403_info'] }
      else
        status, headers, response = @app.call(env)
        Rack::Response.new(response, status, headers)
      end
    end

    private

    def forbidden?
      if restricted_access.include?(request.path)
        session_failed?
      elsif request.path == PLAY_URL
        anonymous? && session_failed?
      end
    end

    def session_failed?
      !request.session[:game]
    end

    def anonymous?
      !request.params['player_name'] || !request.params['level']
    end
  end
end
