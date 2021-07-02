# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class DataSource
  attr_accessor :conn

  def initialize
    @conn = PG.connect(dbname: 'memo_development')
  end

  def all
    @conn.exec("SELECT * FROM memos;");
  end

  def find(id)
    @conn.exec("SELECT * FROM memos where id = '#{id}';")[0];
  end

  def create(params)
    id = Time.now.to_i.to_s
    title = escape_html(params['title'])
    content = escape_html(params['content'])

    @conn.exec("INSERT INTO memos VALUES ('#{id}', '#{title}', '#{content}');")
  end

  def update(params)
    id = params['id']
    title = escape_html(params['title'])
    content = escape_html(params['content'])

    @conn.exec("UPDATE memos SET title='#{title}', content='#{content}' WHERE id='#{id}';")
  end

  def destroy(id)
    @conn.exec("DELETE FROM memos WHERE id='#{id}';")
  end

  private

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
  erb :index, locals: { memos: @data_source.all }
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
