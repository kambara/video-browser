require 'uri'

class Entry
  def initialize(path)
    if path.class == String
      path = URI.decode_www_form_component(path)
    end
    path = Pathname(path).cleanpath
    @relative_path =
      if path.absolute?
        path.relative_path_from(video_root_dir).cleanpath
      else
        path
      end
  end

  def absolute_path
    video_root_dir + @relative_path
  end

  def basename
    @relative_path.basename
  end

  def parent_directory
    Directory.new(@relative_path.parent)
  end

  def video_root_dir
    Pathname(Application.settings.video_root)
  end
end
