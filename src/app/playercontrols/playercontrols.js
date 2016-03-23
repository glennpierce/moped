angular.module('moped.playercontrols', [
  'moped.mopidy',
  'moped.util',
  'moped.widgets'
])

.controller('PlayerControlsCtrl', function PlayerControlsController($scope, mopidyservice, allplayservice) {

  $scope.volume = 0;
  $scope.isPlaying = false;
  $scope.isRandom = false;

  $scope.$on('moped:slidervaluechanged', function(event, value) {
    mopidyservice.setVolume(value);
    allplayservice.set_volume(value);
  });

  $scope.$on('mopidy:event:playbackStateChanged', function(event, data) {
    $scope.isPlaying = data.new_state === 'playing';
    $scope.$apply();    
  });

  $scope.$on('mopidy:state:online', function() {
    mopidyservice.getVolume().then(function(volume) {
      $scope.volume = volume;
    });
    mopidyservice.getState().then(function(state) {
      $scope.isPlaying = state === 'playing';
    });
    mopidyservice.getRandom().then(function (isRandom) {
      $scope.isRandom = isRandom === true;
    });
  });

  $scope.$on('mopidy:event:volumeChanged', function(event, data) {
    $scope.volume = data.volume;
    $scope.$apply();
  });

  $scope.play = function() {
    if ($scope.isPlaying) {
      // pause
      mopidyservice.pause();
      allplayservice.pause();
    }
    else {
      // play
      mopidyservice.play();
      allplayservice.create_zone(JSON.parse(localStorage['moped.selectedDevices']), localStorage['moped.icecastUri']);
    }
  };
  
  $scope.previous = function() {
    mopidyservice.previous();
  };

  $scope.next = function() {
    mopidyservice.next();
  };
  
  $scope.stop = function() {
    mopidyservice.stopPlayback();
    allplayservice.pause();
  };

  $scope.toggleRandom = function () {
    if ($scope.isRandom) {
      mopidyservice.setRandom(false).then(function () {
        $scope.isRandom = false;
      });
    } else {
      mopidyservice.setRandom(true).then(function () {
        $scope.isRandom = true;
      });
    }
  };
});
