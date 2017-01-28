class RandomVideo {
  constructor() {
    $(document).keydown((event) => {
      if (event.key == 'r') {
        $('#random').submit()
      }
    })
  }
}

new RandomVideo()
