# VideoBrowser

## Pre requirements:

- Ruby
- [Video Contact Sheet (vcs)](https://p.outlyer.net/vcs/)
- [VLC Web Browser Plugin (Safari)](http://www.videolan.org/vlc/download-macosx.ja.html)

Install Video Contact Sheet (vcs):

    sudo aptitude install imagemagick mplayer ffmpeg
    sudo dpkg -i vcs.xxx.deb

## Install

rbenv:

    rbenv install 2.4.0

video-browser:

    cd video-browser
    gem install bundler
    rbenv rehash
    bundle install

## Usage

development:

    bundle exec puma --port 8080

production:

    bundle exec puma --config config/puma.rb

## Todo

- ファイル名検索
- ソート方法切り替え
- 指定時間から再生
- サムネイル指定で再生
- サムネイル数変更
- サムネイルキューイング
