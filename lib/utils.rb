module Codebreaker
  module Utils
    private
    def define_session_accessors
      %i[game last_guess marker hint].each do |method|
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

    def error_template(erb_name, status, &message)
      Rack::Response.new(render(erb_name) { message.call }, status)
    end

    def go_to(url)
      Rack::Response.new do |response|
        response.redirect(url)
      end
    end
  end
end
