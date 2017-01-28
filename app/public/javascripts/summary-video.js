class SummaryVideo {
  constructor() {
    this.offset = 30;
    this.durationPerScene = 5;
    this.numberOfScenes = 6;
    this.currentIndex = 0;
    // Video
    this.video = $('#summary');
    this.videoElement = this.video.get(0);
    this.video.one('canplay', () => {
      const duration = this.videoElement.duration
      this.interval = (duration - this.offset) / this.numberOfScenes;
      this.play();
    });
    this.video.on('timeupdate', () => { this.onTimeUpdate(); });
    this.video.on('click', () => { this.onClick(); });
    this.videoElement.volume = 0
  }

  play() {
    this.videoElement.currentTime = this.getStartTime();
    this.videoElement.play();
  }

  onTimeUpdate() {
    if (this.videoElement.currentTime
        > this.getStartTime() + this.durationPerScene) {
      this.videoElement.pause();
      this.video.css('visibility', 'hidden');
      this.currentIndex++;
      if (this.currentIndex > this.numberOfScenes - 1) {
        this.currentIndex = 0;
      }
      setTimeout(() => {
        this.play();
        this.video.one('canplay', () => {
          this.video.css('visibility', 'visible');
        });
      }, 200);
    }
  }

  onClick() {
    if (this.videoElement.paused) {
      this.videoElement.play();
    } else {
      this.videoElement.pause();
    }
  }

  getStartTime() {
    return this.offset + this.interval * this.currentIndex;
  }
}

new SummaryVideo();
