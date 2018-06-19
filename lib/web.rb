require 'erb'

module Codebreaker
  class Web
    include Message
    #include Storage

    def self.call(env)
      new(env).response.finish
    end

    attr_reader :request, :locale

    def initialize(env)
      @request = Rack::Request.new(env)
      @locale = request.session.options[:locale]
    end

    def response
      case request.path
        when '/'
          locale.lang = request.cookies['lang'].to_sym if request.cookies['lang']
          Rack::Response.new(render('index.html.erb'))
        when '/change_lang' then change_lang
        else Rack::Response.new(render('404.html.erb'), 404)
      end
    end

    def render(template)
      path = File.expand_path("../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def cookies
      request.cookies['lang']
    end

    private
    def change_lang
      Rack::Response.new do |response|
        response.set_cookie('lang', request.params['lang'])
        response.redirect('/')
      end
    end
  end
end
