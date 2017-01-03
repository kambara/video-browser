#!/usr/bin/env ruby
# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/streaming'
require 'sinatra/config_file'
require 'slim'
require 'sass'
require 'pathname'
require 'fileutils'
require 'uri'
require 'pp'
require 'pry'

config_file 'settings.yml'

before do
  ua = request.user_agent
  @android = ua.match(/android/i) ? true : false
  @video_root = Pathname(settings.video_root)
  @descending = settings.descending || false
  @title = settings.title || 'Video Browser'
end

get '/stylesheets/main.css' do
  scss :'scss/main'
end

get '/' do
  render_index('')
end

get '/list/*' do |path|
  render_index(path)
end

def render_index(path)
  protected!
  @image_offset_top = settings.image_offset_top
  @relative_dir_path = decode_path(path)
  current_dir = @video_root + @relative_dir_path
  @children = current_dir.children.sort
  if @descending
    @children.reverse!
  end
  slim :index
end

get '/thumbnails/*' do |path|
  relative_video_file_path = decode_path(path)
  content_type 'image/jpeg'
  send_file thumbnail_path(relative_video_file_path.parent, relative_video_file_path.basename)
end

get '/videos/*' do |path|
  @relative_video_path = decode_path(path)
  slim :video
end

get '/video-file/*' do |path|
  relative_video_path = decode_path(path)
  video_path = @video_root + relative_video_path
  http_headers = request.env.select { |k, v| k.start_with?('HTTP_')}
  mimetype = `file -Ib "#{video_path}"`.gsub(/\n/,"")
  send_file(video_path,
            :disposition => 'inline',
            :type => mimetype,
            :file_name => video_path.basename)
end

post '/generate-thumbnails/*' do |path|
  force = params['force'] ? true : false
  recursive = params['recursive'] ? true : false
  relative_path = decode_path(path)
  generate_thumbnails_in_dir(relative_path, force, recursive)
  redirect video_list_url(path)
end

helpers do
  def protected!
    return if (!defined?(settings.username) || !defined?(settings.password))
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and
      @auth.basic? and
      @auth.credentials and
      @auth.credentials == [settings.username, settings.password]
  end

  def video_list_url(dir_path)
    if dir_path.to_s == '.'
      '/'
    else
      "/list/#{URI.encode_www_form_component( dir_path.to_s )}"
    end
  end

  def thumbnails_url(relative_dir_path, video_file_name)
    "/thumbnails/#{ URI.encode_www_form_component( relative_dir_path + video_file_name ) }"
  end

  def sub_dir_thumbnail_url(relative_dir_path, sub_dir_name)
    sub_dir_path = @video_root + relative_dir_path + sub_dir_name
    sub_dir_path.children.sort.each do |child|
      if is_video(child)
        return thumbnail_url(relative_dir_path + sub_dir_name, child.basename)
      end
    end
    ""
  end

  def child_count(relative_dir_path)
    (@video_root + relative_dir_path).children.select {|child|
      unless child.basename.to_s.match(/^\./)
        if child.directory? || is_video(child)
          next true
        end
      end
      false
    }.length
  end

  def generate_thumbnails_url(dir_path)
    "/generate-thumbnails/#{URI.encode_www_form_component( dir_path.to_s )}"
  end

  def video_page_url(relative_video_path)
    "/video/#{URI.encode_www_form_component( relative_video_path.to_s )}"
  end

  def video_file_url(relative_video_path)
    "/video-file/#{URI.encode_www_form_component( relative_video_path.to_s )}"
  end

  def decode_path(encoded_path)
    path = URI.decode_www_form_component(encoded_path)
    Pathname(path)
  end

  def generate_thumbnails_in_dir(relative_path, force=false, recursive=false)
    current_dir = @video_root + relative_path
    current_dir.each_child do |child|
      if child.file?
        if is_video(child)
          generate_thumbnail(child, relative_path, force)
        end
      elsif recursive
        generate_thumbnails_in_dir(relative_path + child.basename, force, recursive)
      end
    end
  end

  def is_video(path)
    if (path.file? &&
        !path.basename.to_s.match(/^\./) &&
        path.extname.match(/\.(mp4|mkv|m4v|avi|wmv|mpg|mpeg)/i))
      true
    else
      false
    end
  end

  def generate_thumbnail(video_file_path, relative_dir_path, force=false)
    thumb_path = thumbnail_path(relative_dir_path, video_file_path.basename.to_s)
    if thumb_path.exist?
      if force
        FileUtils.rm_rf(thumb_path)
      else
        return
      end
    end
    thumb_path.parent.mkpath
    system <<-EOS
      vcs \
        --numcaps=14 \
        --columns=7 \
        --height=100 \
        --jpeg \
        --anonymous \
        --disable padding \
        --disable shadows \
        --override 'bg_heading=white' \
        --override 'bg_sign=white' \
        --override 'fg_heading=#cccccc' \
        --override 'fg_sign=white' \
        --override 'nonlatin_filenames=1' \
        --output="#{ thumb_path.to_s }" \
        "#{ video_file_path.to_s }"
    EOS
  end

  def thumbnail_path(relative_dir_path, video_file_name)
    Pathname(settings.root) +
      'data/thumbnails' +
      relative_dir_path +
      "#{video_file_name}.jpg"
  end
end
