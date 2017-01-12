# VideoBrowser

## Pre requirements:

- Ruby
- ffmpeg
- [VLC Web Browser Plugin](http://www.videolan.org/vlc/download-macosx.ja.html)

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

    bundle exec puma -p 8080

production:

    bundle exec puma --config config/puma.rb -p 10000 -e production

## Todo

- nginx
- キーボード操作
- ザッピング（ランダムサマリー再生）
- 曖昧検索
- ソート方法切り替え（ランダム）
- サムネイル生成キューイング
- お気に入り時間
