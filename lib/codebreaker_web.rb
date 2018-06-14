require 'erb'
require 'codebreaker'

class CodebreakerWeb
  def self.call(env)
    new(env).response.finish
  end

  attr_reader :request

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case request.path
      when '/' then Rack::Response.new(render('index.html.erb'))
      when '/start_game' then Rack::Response.new(request.params[:player_name])
      else Rack::Response.new('Page not found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
