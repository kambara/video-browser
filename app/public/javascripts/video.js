function main(videoFileUrl) {
  VideoFactory.create(videoFileUrl)
}

class VideoFactory {
  static create(videoFileUrl) {
    if (this.isChrome()) {
      return new Video(videoFileUrl, '.video-container')
    } else {
      return new VlcVideo(videoFileUrl, '.video-container')
    }
  }

  static isChrome() {
    var ua = window.navigator.userAgent.toLowerCase()
    ;(ua.indexOf('chrome') >= 0)
  }
}

class Video {
  constructor(videoFileUrl, container) {
    this.video = this.createElement(videoFileUrl)
    this.videoElement = this.video.get(0)
    $(container).append(this.video)
    $(window).keydown((event) => {
      this.onKeyDown(event)
    })
    this.initVideo()
  }

  createElement(url) {
    const video = $('<video />').attr({
      controls: 'controls',
      preload: 'none',
      src: url
    })
    return video
  }

  initVideo() {
    this.video.css('visibility', 'hidden')
    this.video.one('canplay', () => {
      this.seekAndPlay(this.getInitialTime())
    })
    this.videoElement.load()
  }

  onKeyDown(event) {
    // console.log(event.keyCode)
    switch (event.keyCode) {
      case 37: // Left
        this.seekBackward(10)
        break
      case 39: // Right
        this.seekForward(10)
        break
      case 38: // top
        this.seekForward(60)
        break
      case 40: // Bottom
        this.seekBackward(60)
        break
      case 32: // Space
        this.onSpaceKeyDown()
        break
      case 70: // F
        this.toggleFullscreen()
        break
    }
  }

  onSpaceKeyDown() {
    this.togglePause()
  }

  togglePause() {
    if (this.videoElement.paused) {
      this.videoElement.play()
    } else {
      this.videoElement.pause()
    }
  }

  toggleFullscreen() {
    if (document.webkitIsFullScreen) {
      this.videoElement.webkitExitFullscreen()
    } else {
      this.videoElement.webkitRequestFullscreen()
    }
  }

  seekAndPlay(time) {
    this.video.one('seeked', () => {
      this.video.css('visibility', 'visible')
      this.videoElement.play()
    })
    this.videoElement.currentTime = time
  }

  getCurrentTime() {
    return this.videoElement.currentTime
  }

  seekForward(time) {
    this.seekAndPlay(this.getCurrentTime() + time)
    this.showControls()
  }

  seekBackward(time) {
    this.seekAndPlay(this.getCurrentTime() - time)
    this.showControls()
  }

  showControls() {
    this.videoElement.controls = true
  }

  getInitialTime() {
    if (location.hash.length <= 1) {
      return 0
    }
    var pair = location.hash.substr(1).split('=')
    if (pair[0] == 'time') {
      var time = parseInt(pair[1])
      if (!isNaN(time)) {
        return time
      }
    }
    return 0
  }
}

class VlcVideo extends Video {
  constructor(videoFileUrl, container) {
    super(videoFileUrl, container)
  }

  initVideo() {
    // Reload if plugin error happens
    if (!this.videoElement.input) {
      setTimeout(() => {
        location.reload()
      }, 1000)
      return
    }
    this.seekAndPlay(this.getInitialTime())
  }

  createElement(url) {
    const video = $('<embed />').attr({
      target: url,
      type: 'application/x-vlc-plugin',
      pluginspage: 'http://www.videolanorg',
      autostart: false,
      toolbar: true,
      branding: false,
      width: 0,
      height: 0
    })
    return video
  }

  getCurrentTime() {
    return this.videoElement.input.time / 1000
  }

  showControls() {
  }

  onSpaceKeyDown() {
  }

  toggleFullscreen() {
    this.videoElement.video.toggleFullscreen()
    this.videoElement.focus()
  }

  seekAndPlay(time) {
    if (this.videoElement.input.state != 4) {
      this.videoElement.playlist.play()
    }
    this.videoElement.input.time = time * 1000
  }
}
