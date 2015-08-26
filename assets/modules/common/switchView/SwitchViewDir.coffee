app.directive 'switch', [
  '$http'
  ($http) ->
    # Runs during compile
    {
      restrict: 'E'
      templateUrl: "templates/common/switchView/switchView.html"
      replace: true
      scope:
        position:"@"
      controller: ($scope,$element,$attrs)->
        $scope.roles = []

        # get all roles available for this user and assign it to $scope.roles
        $http.get "/session/types"
        .success (roles)->
          $scope.roles = roles
          return


        # set new active view in the session and refresh
        $scope.change = (roleId)->
          $http.put "/session/change/"+roleId
          .success (status)->
            document.location = '/' if status.success
          return
        return
    }
]
