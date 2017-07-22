# VideoBrowser

## Pre requirements:

- Ruby
- ffmpeg
- [VLC Web Browser Plugin](http://www.videolan.org/vlc/download-macosx.ja.html)
- nginx (optional)

## Install

    git clone git@github.com:kambara/video-browser.git
    cd video-browser
    gem install bundler
    bundle install

### nginx (optional)

    sudo cp utils/nginx/nginx.conf /etc/nginx/sites-available/<APP_NAME>
    sudo vi /etc/nginx/sites-available/<APP_NAME>
    sudo ln -s /etc/nginx/sites-available/<APP_NAME> /etc/nginx/sites-enabled/
    sudo systemctl restart nginx

### Register as a systemd service (optional)

    sudo cp utils/systemd/video-browser.service /etc/systemd/system/<APP_NAME>.service
    sudo vi /etc/systemd/system/<APP_NAME>.service
    sudo systemctl daemon-reload
    sudo systemctl enable <APP_NAME>

## Usage

development:

    bundle exec puma -p 8080

production (standalone):

    bundle exec puma --config config/puma.rb -p 10000 -e production

production (with nginx):

    bundle exec puma --config config/puma.rb -e production

systemd:

    sudo systemctl start <APP_NAME>

## Todo

- キーボード操作
- ザッピング（ランダムサマリー再生）
- 曖昧検索
- ソート方法切り替え（ランダム）
- サムネイル生成キューイング
- お気に入り時間
