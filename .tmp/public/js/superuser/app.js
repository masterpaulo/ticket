var app;

app = angular.module('superApp', ["ngMeditab", 'ngRoute', 'ngMaterial', "ngAnimate", "ngResource", "ngAria", "angular-click-outside"]);

app.config([
  "$routeProvider", "$locationProvider", "$httpProvider", "$sceDelegateProvider", "meditabApiUrlProvider", "$mdThemingProvider", function($routeProvider, $locationProvider, $httpProvider, $sceDelegateProvider, meditabApiUrlProvider, $mdThemingProvider) {
    var apiConfig;
    $locationProvider.html5Mode(true);
    $mdThemingProvider.theme('default').primaryPalette('blue-grey', {
      'default': '900',
      'hue-1': '500',
      'hue-2': '600',
      'hue-3': '700'
    }).accentPalette('teal', {
      'default': '500'
    }).warnPalette('pink');
    $routeProvider.when('/', {
      templateUrl: 'templates/superuser/super/super.html',
      controller: 'SuperCtrl'
    });
    apiConfig = {
      api: "http://api.meditab.com",
      port: 80
    };
    return meditabApiUrlProvider.set(apiConfig);
  }
]);

//# sourceMappingURL=app.js.map
