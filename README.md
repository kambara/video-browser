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

## Start

    ruby main.rb -e production
