require 'bundler'
Bundler.require

require 'yaml'
require 'json'
require 'digest/sha1'
require 'open-uri'

class Database
  def initialize(path)
    data_loaded = Dir[File.join(path, '*.yaml')].map do |yaml_path|
      hash = YAML.load_file(yaml_path)
      id = File.basename(yaml_path, '.yaml')
      hash['url'] = "/glitch?url=#{hash['url']}"
      hash.merge(id: id)
    end
    @data = data_loaded.sort_by do |entry|
      Digest::SHA1.digest(entry[:id])
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
