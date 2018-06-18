require 'erb'
require 'codebreaker'

module Codebreaker
  class Web
    include Message
    include Storage

    def self.call(env)
      new(env).response.finish
    end

    attr_reader :request

    def initialize(env)
      localization_dir = File.expand_path('./locale/.', File.dirname(__FILE__))
      @locale = Localization.new(:web, localization_dir)
      @request = Rack::Request.new(env)
    end

    def response
      case request.path
        when '/' then Rack::Response.new(render('index.html.erb'))
        when '/start_game' then Rack::Response.new(request.params[:player_name])
        else Rack::Response.new(render('404.html.erb'), 404)
      end
    end

    def render(template)
      path = File.expand_path("../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end
  end
end
