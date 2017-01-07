require 'pathname'
require 'fileutils'
require 'systemu'

class ThumbnailList
  def initialize(video)
    @video = video
  end

  def to_a
    unless directory.exist?
      return []
    end
    directory.children.select {|child|
      child.file? && child.basename.to_s.match(/^\d+\.jpg$/)
    }.map {|image_file|
      number = image_file.basename('.jpg').to_s.to_i
      Thumbnail.new(@video.key, number)
    }.sort_by {|thumb|
      thumb.number
    }
  end

  def representatives
    max = 6 * 1
    thumbnails = to_a
    thumbnails.shift
    if thumbnails.length <= max
      return thumbnails
    end
    thumbs = (0...max).map do |count|
      i = (thumbnails.length * count / max.to_f).floor
      thumbnails[i]
    end
    thumbs
  end

  def create(force=false)
    if directory.exist?
      if force
        FileUtils.rm_rf(directory)
      else
        return
      end
    end
    duration = @video.duration
    return unless duration
    directory.mkpath
    puts "Create thumbnail: #{@video.basename}"
    number = (duration / Application.settings.thumbnail_interval).floor
    if number == 0
      number = 1
    end
    number.times do |n|
      puts "#{n+1}/#{number}"
      Thumbnail.new(@video.key, n).create(@video.absolute_path)
    end
  end

  def directory
    Thumbnail.new(@video.key, 0).absolute_path.parent
  end
end

class Thumbnail
  attr_reader :number

  def initialize(video_key, number)
    @video_key = video_key
    @number = number.to_i
  end

  def absolute_path
    # ThumbnailList.new(@video_key).directory + "#{ @number.to_s }.jpg"
    Pathname(Application.settings.root).parent +
      'data/thumbnails' +
      @video_key +
      Application.settings.thumbnail_interval.to_s +
      "#{ @number.to_s }.jpg"
  end

  def url
    interval = Application.settings.thumbnail_interval
    "/thumbnail/#{ @video_key }/#{ interval }/#{ @number.to_s }.jpg"
  end

  def time
    @number * Application.settings.thumbnail_interval.to_i
  end

  def create(video_path)
    status, stdout, stderr = systemu <<-EOS
      ffmpeg \
        -ss #{ time } \
        -i "#{ video_path.to_s }" \
        -vframes 1 \
        -vf "scale=iw*sar*(100/ih):100" \
        -f image2 \
        -vsync 0 \
        -y \
        -an \
        "#{ absolute_path.to_s }"
    EOS
    unless status.success?
      puts stderr
    end
  end
end
