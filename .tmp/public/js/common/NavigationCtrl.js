app.controller("NavigatorCtrl", [
  "$scope", "$location", "$timeout", "$http", "$routeParams", function($s, $l, $t, $x, $rp) {
    $s.active = function(url) {
      var i, path;
      path = $l.path() || document.location.pathname;
      if (url !== "/") {
        i = path.indexOf(url);
        return i > -1;
      } else {
        return path === url;
      }
    };
    $s.menus = [];
    $s.logout = function() {
      return document.location = '/logout';
    };
    $s.select = function(submenuId) {
      $s.menus.forEach(function(m) {
        m.active = false;
        return m.submenus.forEach(function(s) {
          if (s.id === submenuId) {
            s.active = true;
            m.active = true;
          } else {
            s.active = false;
          }
        });
      });
    };
    $s.$on("$routeChangeSuccess", function() {
      $s.select(+$rp.submenuId);
    });
  }
]);


/*

 $scope.$on('$routeChangeSuccess', function () {
            var items = $scope.items;
            var path = $location.path();

            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                var href = item['href'];
                item['current'] = !!href && href.substring(1) === path;
            }
        });
 */

//# sourceMappingURL=NavigationCtrl.js.map
