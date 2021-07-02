# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

class DataSource
  DATA_SOURCE_PATH = './data.json'

  attr_accessor :data

  def initialize
    @data = File.open(DATA_SOURCE_PATH) { |f| JSON.parse(f.read) }
  end

  def find(id)
    @data.find { |m| m['id'] == id }
  end

  def create(params)
    data = {
      'id': Time.now.to_i.to_s,
      'title': escape_html(params['title']),
      'content': escape_html(params['content'])
    }

    @data << data

    json_dump
  end

  def update(params)
    data = find(params['id'])

    data['title'] = escape_html(params['title'])
    data['content'] = escape_html(params['content'])

    json_dump
  end

  def destroy(id)
    index = @data.find_index { |d| d['id'] == id }
    @data.delete_at(index)

    json_dump
  end

  private

  def json_dump
    File.open(DATA_SOURCE_PATH, 'w') do |f|
      JSON.dump(@data, f)
    end
  end

  def escape_html(str)
    Rack::Utils.escape_html(str)
  end
end

helpers do
  def render_show_or_edit(template_symbol)
    memo = @data_source.find(params['id'])

    erb template_symbol, locals: { memo: memo }
  end
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

not_found do
  erb :not_found
end
