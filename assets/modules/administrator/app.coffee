app = angular.module 'ticketApp',["ngMeditab",'ngRoute','ngMaterial',"ngAnimate","ngResource","ngAria", "angular-click-outside"]


# app.controller 'superCtrl', ($scope, $timeout, $mdSidenav, $mdUtil, $log) ->


app.config([ "$routeProvider", "$locationProvider", "$httpProvider","$sceDelegateProvider","meditabApiUrlProvider", "$mdThemingProvider"
  ($routeProvider, $locationProvider, $httpProvider,$sceDelegateProvider,meditabApiUrlProvider, $mdThemingProvider) ->
    $locationProvider.html5Mode true


    $mdThemingProvider.theme 'default'
    .primaryPalette 'blue-grey', {
      'default': '900', # by default use shade 400 from the pink palette for primary intentions
      'hue-1': '500', # use shade 100 for the <code>md-hue-1</code> class
      'hue-2': '600', # use shade 600 for the <code>md-hue-2</code> class
      'hue-3': '700' # use shade A100 for the <code>md-hue-3</code> class
    }
    .accentPalette 'teal', {
      'default': '500', # by default use shade 400 from the pink palette for primary intentions
      # 'hue-1': '500', # use shade 100 for the <code>md-hue-1</code> class
      # 'hue-2': '600', # use shade 600 for the <code>md-hue-2</code> class
      # 'hue-3': '700' # use shade A100 for the <code>md-hue-3</code> class

    }
    .warnPalette('pink');




    $routeProvider

    .when '/',
      # template: 'wawa'
      templateUrl: 'templates/administrator/admin/admin.html'
      # template: JST["superuser/super/super.html"]()
      controller: 'AdminCtrl'
    .when '/concern',
      # template: 'wawa'
      templateUrl: 'templates/administrator/admin/concern.html'
      # template: JST["superuser/super/super.html"]()
      controller: 'ConcernCtrl'

    .when '/status',
      # template: 'wawa'
      templateUrl: 'templates/administrator/admin/status.html'
      # template: JST["superuser/super/super.html"]()
      controller: 'StatusCtrl'

    .otherwise redirectTo: '/'

    apiConfig =
      api: "http://api.meditab.com"
      port: 80
      # api: "http://localhost"
      # port: 3000

    meditabApiUrlProvider.set apiConfig
])
#

#


