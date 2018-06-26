module Codebreaker
  module Utils
    private

    def define_session_accessors
      %i[game scores last_guess marker hint].each do |method|
        self.class.class_eval do
          define_method "#{method}" do
            request.session[method]
          end

          define_method "#{method}=" do |value|
            request.session[method] = value
          end
        end
      end
    end

    def render(template)
      path = File.expand_path("../views/#{template}.html.erb", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def template(erb_name)
      Rack::Response.new(render(erb_name))
    end

    def error_template(erb_name, status, &err_msg)
      Rack::Response.new(render(erb_name) { err_msg.call }, status)
    end

    def go_to(url)
      Rack::Response.new do |response|
        response.redirect(url)
      end
    end

    def referer
      root_url = '/'
      return root_url unless request.referer
      url = request.referer[/\A.+\/{2}.+(\/.+)\z/,1]
      url ? url : root_url
    end

    def first_attempt?
      game.attempts == game.configuration.max_attempts
    end

    def load_scores
      self.scores = load_game_data
    end

    def game_over?
      game.won? || game.attempts.zero?
    end

    def hints_allowed?
      !game_over? && game.hints.positive?
    end

    def save_game_data
      save_user_score
      save_to_yml
    end
  end
end
