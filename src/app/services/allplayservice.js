angular.module('moped.allplay', [])
  .factory('allplayservice', function($q, $rootScope, $http) {

    //var consoleLog = console.log.bind(console);
    var consoleLog = function () {};
    var consoleError = console.error.bind(console);

    return {
      create_zone: function(selected_devices, icecast_uri) {
          var json_data = JSON.stringify({'selected_devices': selected_devices,
                                          'icecastUri': icecast_uri});
          $http({cache: false, url: '/moped/create_zone', method: 'POST', data: json_data});
      },
      resetup_zone: function() {
        $http({cache: false, url: '/moped/resetup_zone', method: 'GET'});
      },
      play: function() {
        $http({cache: false, url: '/moped/play', method: 'GET'});
      },
      stop: function() {
        $http({cache: false, url: '/moped/stop', method: 'GET'});
      },
      play_uri: function(icecast_uri) {
        var json_data = JSON.stringify({'icecastUri': icecast_uri});
        $http({cache: false, url: '/moped/create_zone', method: 'POST', data: json_data});
      },
      play_lasturi: function() {
        $http({cache: false, url: '/moped/play_lasturi', method: 'GET'});
      },
      pause: function() {
        $http({cache: false, url: '/moped/pause', method: 'GET'});
      },
      resume: function() {
        $http({cache: false, url: '/moped/resume', method: 'GET'});
      },
      get_devices: function() {
        return $http({ cache: false, url: '/moped/get_devices', method: 'GET'});
      }
    };
  });
