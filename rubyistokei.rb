require 'bundler'
Bundler.require

require 'yaml'
require 'json'
require 'digest/sha1'
require 'open-uri'
RUBYISTOKEI_DATA = 'http://rubyistokei.herokuapp.com/data.json'

class Database
  def initialize(path)
    @data = JSON.parse(open(RUBYISTOKEI_DATA).read)
    @data.each do |entry|
      entry['url'] = "/glitch?url=#{entry['url']}"
    end
  end

  attr_reader :data
end

module Rubyistokei
  class Application < Sinatra::Application
    configure do
      set :protection, :except => :frame_options

      DATA_PATH = File.join(__dir__, 'data')
    end

    get '/' do
      haml :index
    end

    get '/glitch' do
      data = open(params[:url]).read
      data_a = data[0 .. data.size / 2]
      data_b = data[data.size / 2 .. -1]
      content_type :jpeg
      data_a + data_b.force_encoding('ascii-8bit').gsub('a', 'b')
    end

    get '/css/screen.css' do
      scss :screen
    end

    get '/data.json' do
      content_type :json
      database = Database.new(DATA_PATH)
      JSON.dump(database.data)
    end
  end
end
