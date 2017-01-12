#!/usr/bin/env ruby

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'slim'
require 'haml'
require 'sass'
require 'pathname'
require 'pry-byebug'
require 'sinatra/paginate'
require_relative 'models/directory'
require_relative 'models/video'

Struct.new('Result', :total, :size, :entries)

class Application < Sinatra::Base
  register Sinatra::Paginate
  register Sinatra::ConfigFile
  config_file Pathname(settings.root) + '../config/settings.yml'

  configure :development do |config|
    register Sinatra::Reloader
    config.also_reload './app/*/*.rb'
  end

  get '/stylesheets/main.css' do
    scss :'scss/main'
  end

  get '/' do
    directory_index('.')
  end

  get '/directory/*' do |path|
    directory_index(path)
  end

  def directory_index(path)
    protected!
    @directory = Directory.new(path)
    entries = @directory.entries[current_page * entries_per_page, entries_per_page]
    @result = Struct::Result.new(
      @directory.entries.length,
      entries.length,
      entries
    )
    slim :directory
  end

  post '/search' do
    params[:keyword]
    directory = Directory.new('.')
    @entries = directory.search(params[:keyword])
    slim :search
  end

  get '/video/*.html' do |path|
    protected!
    @video = Video.new(path)
    slim :video
  end

  get '/video-scenes/*.html' do |path|
    protected!
    @video = Video.new(path)
    slim :video_scenes
  end

  get '/video-file-proxy/*.link' do |path|
    video = Video.new(path)
    video.make_symlink
    redirect video.file_url, 302
  end

  get '/video-file/*.mp4' do |key|
    video_file = Video.key_to_link(key)
    send_file(
      video_file,
      disposition: 'inline',
      type: Video.mimetype(video_file),
      file_name: video_file.basename
    )
  end

  get '/thumbnail/*/*/*.jpg' do |video_key, _interval, number|
    content_type 'image/jpeg'
    send_file(Thumbnail.new(video_key, number).absolute_path)
  end

  post '/create-thumbnails/*' do |path|
    force = params['force'] ? true : false
    recursive = params['recursive'] ? true : false
    directory = Directory.new(path)
    directory.create_thumbnails(force, recursive)
    redirect directory.url
  end

  helpers do
    def protected!
      return if !defined?(settings.username) || !defined?(settings.password)
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      (
        @auth.provided? &&
        @auth.basic? &&
        @auth.credentials &&
        @auth.credentials == [settings.username, settings.password]
      )
    end

    def title
      settings.title || 'VIDEO BROWSER'
    end

    def android?
      request.user_agent.downcase.index('android') ? true : false
    end

    def video_page_or_intent(video, time=0)
      if android?
        video.intent_uri(env['HTTP_HOST'], time)
      else
        video.page_url(time)
      end
    end

    def current_page
      [params[:page].to_i - 1, 0].max
    end

    def entries_per_page
      settings.entries_per_page || 100
    end
  end
end
