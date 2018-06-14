require 'securerandom'
require_relative 'lib/codebreaker_web'

use Rack::Reloader, 0
use Rack::Session::Cookie, secret: SecureRandom.alphanumeric

run Rack::Cascade.new([Rack::File.new('public'), CodebreakerWeb])
