module Codebreaker
  class ErrorLogger
    attr_reader :request, :status

    def initialize(app)
      @app = app
    end

    def call(env)
      @status, headers, response = @app.call(env)
      @request = Rack::Request.new(env)
      write_log if [403, 404, 500].include?(status)
      Rack::Response.new(response, status, headers)
    end

    private

    def write_log
      log = File.expand_path('../error.log', File.dirname(__FILE__))
      File.open(log, 'a+') { |data| data.puts error_data }
    end

    def error_data
      "#{request.ip} #{status} #{request.path} #{Time.now}"
    end
  end
end
