# VideoBrowser

## Pre requirements:

- Ruby
- [Video Contact Sheet (vcs)](https://p.outlyer.net/vcs/)
- [VLC Web Browser Plugin (Safari)](http://www.videolan.org/vlc/download-macosx.ja.html)

Video Contact Sheet (vcs):

    sudo aptitude install imagemagick mplayer ffmpeg
    sudo dpkg -i vcs.***.deb

## Install

rbenv:

    rbenv install 2.4.0
    rbenv local 2.4.0

video-browser:

    cd video-browser
    gem install bundler
    rbenv rehash
    bundle install

## Usage

    ruby main.rb -e production

## Todo

- ファイル名検索
- ソート方法切り替え
- 指定時間から再生
- サムネイル指定で再生
- サムネイル数変更
- サムネイルキューイング
- 認証
