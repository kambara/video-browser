require_relative 'entry'
require_relative 'video'

class Directory < Entry
  def entries
    results = absolute_path.children.select {|child|
      if child.basename.to_s.match /^\./
        next false
      end
      (child.directory? || is_video(child))
    }.map {|child|
      if is_video(child)
        Video.new(child)
      else
        Directory.new(child)
      end
    }.sort_by {|entry|
      entry.basename
    }
    if Application.settings.descending
      results.reverse
    else
      results
    end
  end

  def url
    if root?
      '/'
    else
      "/directory/#{URI.encode_www_form_component( @relative_path.to_s )}"
    end
  end

  def first_video
    entries.each do |entry|
      if entry.class == Video
        return entry
      end
    end
    ## Scan deeper folders
    entries.each do |entry|
      if entry.class == Directory
        video = entry.first_video
        return video if video
      end
    end
    nil
  end

  def thumbnail_creation_url
    "/create-thumbnails/#{URI.encode_www_form_component( @relative_path.to_s )}"
  end

  def create_thumbnails(force=false, recursive=false)
    entries.each do |entry|
      if entry.class == Video
        entry.create_thumbnail(force)
      elsif entry.class == Directory
        if recursive
          entry.create_thumbnails(force, recursive)
        end
      end
    end
  end

  def root?
    @relative_path.cleanpath.to_s == '.'
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
end
