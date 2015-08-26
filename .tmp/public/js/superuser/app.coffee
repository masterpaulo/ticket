app = angular.module 'superApp',["ngMeditab",'ngRoute','ngMaterial',"ngAnimate","ngResource","ngAria", "angular-click-outside"]


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
      templateUrl: 'templates/superuser/super/super.html'
      # template: JST["superuser/super/super.html"]()
      controller: 'SuperCtrl'

    # .otherwise redirectTo: '/'

    apiConfig =
      api: "http://api.meditab.com"
      port: 80
      # api: "http://localhost"
      # port: 3000

    meditabApiUrlProvider.set apiConfig
])
#

#


