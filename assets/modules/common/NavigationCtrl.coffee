
app.controller "NavigatorCtrl" , [
  "$scope"
  "$location"
  "$timeout"
  "$http"
  "$routeParams"
  ($s, $l, $t, $x, $rp)->
    $s.active = (url)->
      path = $l.path() || document.location.pathname
      if url isnt "/"
        i = path.indexOf url
        return i > -1
      else
        return path is url

    $s.menus = []

    $s.logout = ->
      document.location = '/logout'

    $s.select = (submenuId)->
      $s.menus.forEach (m)->
        m.active = false
        m.submenus.forEach (s)->
          if s.id is submenuId
            s.active = true
            m.active = true
          else
            s.active = false
          return
      return
    $s.$on "$routeChangeSuccess", ->
      $s.select +$rp.submenuId
      return
    return
]

###

 $scope.$on('$routeChangeSuccess', function () {
            var items = $scope.items;
            var path = $location.path();

            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                var href = item['href'];
                item['current'] = !!href && href.substring(1) === path;
            }
        });
###
