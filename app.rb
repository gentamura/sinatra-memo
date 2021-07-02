require 'sinatra'
require 'sinatra/reloader'
require 'json'

class DataSource
  DATA_SOURCE_PATH = './data.json'.freeze

  attr_accessor :data

  def initialize
    @data = File.open(DATA_SOURCE_PATH) { |f| JSON.load(f) }
  end

  def find(id)
    @data.find {|m| m['id'] == id }
  end

  def create(params)
    data = {
      'id': Time.now.to_i.to_s,
      'title': params['title'],
      'content': params['content']
    }

    @data << data

    open(DATA_SOURCE_PATH, 'w') do |f|
      JSON.dump(@data, f)
    end
  end

  def update(params)
    data = find(params['id'])

    data['title'] = params['title']
    data['content'] = params['content']

    open(DATA_SOURCE_PATH, 'w') do |f|
      JSON.dump(@data, f)
    end
  end

  def destroy(id)
    index = @data.find_index {|d| d['id'] == id }
    @data.delete_at(index)

    open(DATA_SOURCE_PATH, 'w') do |f|
      JSON.dump(@data, f)
    end
  end
end

def render_show_or_edit(template_symbol)
  memo = @data_source.find(params['id'])

  erb template_symbol, locals: { memo: memo }
end


before do
  @data_source = DataSource.new
end

get '/' do
  erb :index, locals: { memos: @data_source.data }
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  @data_source.create(params)

  redirect to('/')
end

get '/memos/:id' do
  render_show_or_edit(:show)
end

get '/memos/:id/edit' do
  render_show_or_edit(:edit)
end

patch '/memos/:id' do
  @data_source.update(params)

  redirect to("/memos/#{params['id']}")
end

delete '/memos/:id' do
  @data_source.destroy(params['id'])

  redirect to('/')
end
