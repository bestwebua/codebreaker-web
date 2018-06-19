require 'codebreaker'
require 'erb'
require 'securerandom'
require_relative 'lib/web'

localization_dir = File.expand_path('./lib/locale/.', File.dirname(__FILE__))

use Rack::Reloader, 0
use Rack::Session::Cookie,
      secret: SecureRandom.alphanumeric,
      locale: Codebreaker::Localization.new(:web, localization_dir)

run Rack::Cascade.new([Rack::File.new('public'), Codebreaker::Web])
