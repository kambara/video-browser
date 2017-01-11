require 'digest/md5'
require 'systemu'
require_relative 'entry'
require_relative 'thumbnail'

class Video < Entry
  def file_url
    "/video-file/#{URI.encode_www_form_component( @relative_path.to_s )}"
  end

  def page_url(time=0)
    url = "/video/#{URI.encode_www_form_component( @relative_path.to_s )}"
    if time > 0
      url += "#time=#{ time }"
    end
    url
  end

  def scenes_page_url
    "/video-scenes/#{URI.encode_www_form_component( @relative_path.to_s )}.html"
  end

  def intent_uri(host, time=0)
    [
      'intent://',
      host,
      file_url,
      '#',
      [
        'Intent',
        'action=android.intent.action.VIEW',
        'scheme=http',
        'type=video/*',
        "i.position=#{ time * 1000 }",
        'end'
      ].join(';')
    ].join
  end

  def mimetype
    `file -b --mime-type "#{absolute_path}"`.gsub(/\n/,"")
  end

  def duration
    status, stdout, stderr = systemu(%(ffprobe "#{ absolute_path }"))
    return nil unless status.success?
    matched = stderr.match(/Duration: ([\d:\.]+),/)
    return nil unless matched
    elements = matched[1].split(':')
    return nil if elements.length != 3
    time =
      elements[0].to_i * (60*60) +
      elements[1].to_i * 60 +
      elements[2].to_f
    time
  end

  def mp4?
    @relative_path.extname == '.mp4'
  end

  def key
    Digest::MD5.new.update(@relative_path.to_s).to_s
  end

  def thumbnail_list
    ThumbnailList.new(self)
  end

  def create_thumbnail(force=false)
    ThumbnailList.new(self).create(force)
  end
end
