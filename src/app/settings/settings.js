angular.module('moped.settings', [
  'checklist-model',
  'ngRoute',
  'moped.allplay'
])
  .config(function config($routeProvider) {
    $routeProvider
      .when('/settings', {
        templateUrl: 'settings/settings.tpl.html',
        controller: 'SettingsCtrl',
        title: 'Settings'
      });
  })

  .controller('SettingsCtrl', function SettingsController($scope, $rootScope, $window, allplayservice) {
    $scope.settings = {
      mopidyUrl: 'ws://127.0.0.1:6680/mopidy/ws/',
      icecastUri: 'http://192.168.1.5:8000/mopidy.m3u',
      selectedDevices: []
    };

    allplayservice.get_devices().success(

      function (data, status, headers, config) {

         $scope.settings.allplayDevices = data['allplay_devices'];
      }
    );

    if (window.localStorage && localStorage['moped.mopidyUrl'] != null) {
      $scope.settings.mopidyUrl = localStorage['moped.mopidyUrl'];
    }

    if (window.localStorage && localStorage['moped.icecastUri'] != null) {
      $scope.settings.icecastUri = localStorage['moped.icecastUri'];
    }

    if (window.localStorage && localStorage['moped.selectedDevices'] != null && localStorage['moped.selectedDevices'] !== '') {
      $scope.settings.selectedDevices = JSON.parse(localStorage['moped.selectedDevices']);
    }
    
    $scope.saveSettings = function() {
      if (window.localStorage) {

        if ($scope.settings.mopidyUrl !== '' && $scope.settings.mopidyUrl !== null) {
          localStorage['moped.mopidyUrl'] = $scope.settings.mopidyUrl;
        }
        else {
          localStorage['moped.mopidyUrl'] = '';  
        }

        localStorage['moped.icecastUri'] = $scope.settings.icecastUri;
        localStorage['moped.selectedDevices'] = JSON.stringify($scope.settings.selectedDevices);

        allplayservice.create_zone($scope.settings.selectedDevices, $scope.settings.icecastUri);
        
        // Have to change speakers more often and this can get annoying
        // $window.alert('Settings are saved.');
        
        $rootScope.$broadcast('settings:saved');
      }
    };

    $scope.verifyConnection = function(e) {
      e.preventDefault();
      
      var mopidy = new Mopidy({ 
        autoConnect: false,
        webSocketUrl: $scope.settings.mopidyUrl
      });
      mopidy.on(console.log.bind(console));
      mopidy.on('state:online', function() {
        $window.alert('Connection successful.');
      });
      mopidy.on('websocket:error', function(error) {
        $window.alert('Unable to connect to Mopidy server. Check if the url is correct.');
      });

      mopidy.connect();

      setTimeout(function() {
        mopidy.close();
        mopidy.off();
        mopidy = null;
        console.log('Mopidy closed.');
      }, 1000);
    };
  });