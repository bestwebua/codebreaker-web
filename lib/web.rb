require_relative 'session'

module Codebreaker
  class Web
    include Message
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
        when '/' then index
        when '/change_lang'   then change_lang
        when '/start_game'    then start_game
        when '/show_hint'     then show_hint
        when '/submit_answer' then submit_answer
        when '/finish_game'   then finish_game
        else Rack::Response.new(render('404.html.erb'), 404)
      end
    end

    def render(template)
      path = File.expand_path("../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def cookies
      #Cookies: #{request.cookies} 
      # "Params: #{request.session.keys}"
    end

    private
    def change_lang
      Rack::Response.new do |response|
        response.set_cookie('lang', request.params['lang'])
        response.redirect('/')
      end
    end

    def index
      locale.lang = request.cookies['lang'].to_sym if request.cookies['lang']
      Rack::Response.new(render('index.html.erb'))
    end

    def start_game
      Rack::Response.new do |response|
        response.set_cookie('level', request.params['level'])
        response.redirect('/')
      end
    end

    def show_hint
      ###
    end

    def submit_answer
      ###
    end

    def finish_game
      ###
    end
  end
end
