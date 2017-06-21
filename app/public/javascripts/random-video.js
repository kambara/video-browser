class RandomVideo {
  constructor() {
    $(document).keydown((event) => {
      console.log(event.key)
      if (event.key == 'F1') {
        $('#random').submit()
      }
    })
  }
}

new RandomVideo()
