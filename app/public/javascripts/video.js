function main() {
  if ($('#player').length > 0) {
    initVideoPlayer();
  } else if (getVlcPlayer() && !isChrome()) {
    initVlcPlayer();
  }
}

function isChrome() {
  var ua = window.navigator.userAgent.toLowerCase();
  if (ua.indexOf('chrome') >= 0) {
    return true;
  }
  return false;
}

function initVideoPlayer() {
  var player = $('#player');
  var playerElement = player.get(0);
  player.css('visibility', 'hidden');
  player.on('canplay', function() {
    player.on('seeked', function() {
      player.css('visibility', 'visible');
      playerElement.play();
      player.off('seeked');
    });
    playerElement.currentTime = getStartTime();
    player.off('canplay');
  });
}

function initVlcPlayer() {
  var vlc = $('#vlc').get(0);
  if (!vlc.input) {
    setTimeout(function() {
      location.reload();
    }, 1000);
    return;
  }
  vlc.input.time = getStartTime() * 1000;
}

function getStartTime() {
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

main();
