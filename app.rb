require 'yaml'
require 'json'

require 'prawn'
require 'prawn-print'

require 'thin'
require 'sinatra'
require 'rack/csrf'
require 'sinatra/flash'

require 'bcrypt'
require 'active_record'

require 'uri'
require 'net/http'

require_relative 'models/master'

begin
  $CONFIG = YAML.load_file('config.yml').freeze
  $ROOT  = File.dirname(__FILE__)

  def assert_config(field)
    raise "The config file is missing #{field}" unless $CONFIG.has_key?(field)
  end

  assert_config(:connection)
  assert_config(:initial_users)
  assert_config(:site_title)
  assert_config(:site_name)
  assert_config(:min_description_length)
  assert_config(:secret)
rescue Exception => e
  puts e
  puts "The config file 'config.yml' is missing."
end

ActiveRecord::Base.establish_connection($CONFIG[:connection])

class Kiosk < Sinatra::Base
  register Sinatra::Flash
  set :public_folder, $ROOT + "/public"

  configure do
#    use Rack::Csrf, :raise => true
    use Rack::Session::Cookie, :secret => $CONFIG[:secret]

    Code.initN($CONFIG[:initial_users]) if Code.count == 0
  end

  require_relative 'routes/main'
end
