function main() {
  if ($('video').length > 0) {
    new Video();
  } else if ($('embed').length > 0 && !isChrome()) {
    new VlcVideo();
  }
}

function isChrome() {
  var ua = window.navigator.userAgent.toLowerCase();
  if (ua.indexOf('chrome') >= 0) {
    return true;
  }
  return false;
}

class Video {
  constructor() {
    this.video = $('#video');
    this.videoElement = this.video.get(0);
    this.initVideo();
    $(window).keydown((event) => {
      //console.log(event.which)
      let time = 10;
      if (event.altKey) {
        time = 60;
      }
      switch (event.keyCode) {
        case 37: // Left
          this.seekBackward(time);
          break;
        case 39: // Right
          this.seekForward(time);
          break;
      }
    });
  }

  initVideo() {
    this.video.css('visibility', 'hidden');
    this.video.one('canplay', () => {
      this.seekAndPlay(this.getInitialTime());
    });
  }

  seekAndPlay(time) {
    this.video.one('seeked', () => {
      this.video.css('visibility', 'visible');
      this.videoElement.play();
    });
    this.videoElement.currentTime = time;
  }

  getCurrentTime() {
    return this.videoElement.currentTime;
  }

  seekForward(time) {
    this.seekAndPlay(this.getCurrentTime() + time);
  }

  seekBackward(time) {
    this.seekAndPlay(this.getCurrentTime() - time);
  }

  getInitialTime() {
    if (location.hash.length <= 1) {
      return 0;
    }
    var pair = location.hash.substr(1).split('=');
    if (pair[0] == 'time') {
      var time = parseInt(pair[1]);
      if (!isNaN(time)) {
        return time;
      }
    }
    return 0;
  }
}

class VlcVideo extends Video {
  constructor() {
    super();
  }

  initVideo() {
    // Reload if plugin error happens
    if (!this.videoElement.input) {
      setTimeout(() => {
        location.reload();
      }, 1000);
      return;
    }
    this.seekAndPlay(this.getInitialTime());
  }

  seekAndPlay(time) {
    this.videoElement.input.time = time * 1000;
  }
}

main();
