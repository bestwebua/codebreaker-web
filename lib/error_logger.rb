require 'pry'

module Codebreaker
  class ErrorLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      Rack::Request.new(env)
      status, headers, response = @app.call(env)
      #status # как получить статус отданный предыдущим слоем? Его тут просто нет...
      Rack::Response.new(response, status, headers)
    end
  end
end
