var common_methods;

app.controller('SuperCtrl', function(ApiObject, $scope, $timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory) {
  var APPS, COMPANY, PROFILE, USER, USERROLE, buildToggler;
  $scope.scopes = [];
  $scope.users = [];
  $scope.userSearch = '';
  $scope.search = '';
  $scope.scopes = [];
  $scope.scopes = ScopeFactory.query();
  $scope.addScopeForm = {};
  $scope.selectedScope = null;
  $scope.editScopeForm = {};
  $scope.selected = false;
  $scope.adminIds = [];
  $scope.scopes = ScopeFactory.query();
  USER = new ApiObject("appuser");
  PROFILE = new ApiObject("profile");
  COMPANY = new ApiObject("company");
  APPS = new ApiObject("token");
  USERROLE = new ApiObject("userrole");
  buildToggler = function(navID) {
    var debounceFn;
    $scope.addScopeForm.name = '';
    debounceFn = $mdUtil.debounce((function() {
      $mdSidenav(navID).toggle().then(function() {
        $log.debug('toggle ' + navID + ' is done');
      });
    }), 200);
    return debounceFn;
  };
  $scope.toggleRight = buildToggler('right');
  $scope.close = function() {
    $mdSidenav('right').close().then(function() {
      $log.debug('close RIGHT is done');
    });
  };
  $scope.toAddScope = function(event, err) {
    if (err) {
      console.log(err);
      return;
    }
    $scope.toEdit = false;
    return $scope.toggleRight();
  };
  $scope.addScope = function(event, err) {
    var newScope, sample;
    if (err) {
      console.log(err);
      return;
    }
    newScope = $scope.addScopeForm;
    return sample = ScopeFactory.query({
      name: newScope.name
    }, function(successRes) {
      var saveScope;
      if (sample.length > 0) {
        console.log("Name already exists");
      } else {
        console.log("Scope added");
        saveScope = ScopeFactory.save(newScope, function(successRes) {
          $scope.scopes.push($scope.addScopeForm);
          $scope.close();
          $scope.addScopeForm = {};
          $scope.refresh();
        }, function(errRes) {
          console.log(errRes);
        });
      }
    });
  };
  $scope.toEditScope = function(event, err) {
    if (err) {
      console.log(errRes);
      return;
    }
    $scope.editScopeForm.name = $scope.selectedScope.name;
    $scope.toEdit = true;
    $scope.toggleRight();
  };
  $scope.editScope = function(event, err) {
    var newScope, scopeId;
    if (err) {
      console.log(err);
      return;
    }
    scopeId = $scope.selectedScope.id;
    newScope = $scope.editScopeForm;
    ScopeFactory.get({
      id: scopeId
    }, function(saveScope) {
      saveScope.name = newScope.name;
      saveScope.$save(function() {
        return $scope.refresh();
      });
      $scope.selectedScope = saveScope;
      return $scope.close();
    });
    $scope.toEdit = false;
    $scope.editScopeForm = {};
    $scope.refresh();
  };
  $scope.refresh = function() {
    $scope.scopes = ScopeFactory.query();
  };
  $scope.selectScope = function(scope) {
    $scope.selected = true;
    $scope.selectedScope = scope;
    $scope.fillAdminList();
  };
  $scope.fillAdminList = function() {
    var test;
    $scope.adminIds = [];
    test = ScopeFactory.get({
      id: $scope.selectedScope.id
    }, function(successRes) {
      $scope.selectedScope.admins = test.admins;
      $scope.selectedScope.admins.forEach(function(admin, i) {
        var userId;
        userId = admin.userId;
        $scope.adminIds.push(userId);
        return USER.find({
          id: userId
        }).populate('profileId').exec(function(err, data) {
          var appuser;
          if (data.length > -1) {
            appuser = data[0].profileId;
            $scope.selectedScope.admins[i].name = appuser.firstName + " " + appuser.lastName;
          }
        });
      });
    });
  };
  $scope.adminExist = function(user) {
    if (($scope.adminIds.indexOf(user.id)) > -1) {
      return true;
    } else {
      return false;
    }
  };
  $scope.addAdmin = function(user, scope) {
    var data;
    console.log(user.id);
    console.log(scope.id);
    $scope.search = "";
    data = {
      scopeId: scope.id,
      userId: user.id
    };
    AdminFactory.save(data, function(successRes) {
      console.log(successRes);
      $scope.fillAdminList();
    }, function(errRes) {
      console.log(errRes);
    });
  };
  $scope.deleteAdmin = function(adminId) {
    console.log("deleting admin : " + adminId);
    console.log(AdminFactory["delete"]({
      id: adminId
    }, function(successRes) {
      return $scope.fillAdminList();
    }, function(errRes) {
      return console.log(errRes);
    }));
  };
  return $scope.searchUser = function() {
    var doReset, query1, query2, reset;
    reset = false;
    doReset = function() {
      if (!reset) {
        reset = true;
        return $scope.users = [];
      }
    };
    if ($scope.search.length > 3) {
      reset = false;
      $scope.users = [];
      query1 = {
        or: [
          {
            email: {
              'contains': "" + $scope.search
            }
          }, {
            username: {
              'contains': "" + $scope.search
            }
          }
        ]
      };
      USER.find(query1).populate("profileId").exec(function(err, data) {
        var l, userExists;
        doReset();
        if (err) {
          return console.log(err);
        } else if (data.length) {
          l = $scope.users.length;
          if (l > 0) {
            userExists = $scope.users.map(function(e) {
              return e.id;
            });
          }
          return data.forEach(function(user) {
            if (!l || (userExists.indexOf(user.id)) === -1) {
              return $scope.users.push(user);
            }
          });
        }
      });
      query2 = {
        or: [
          {
            firstName: {
              'contains': "" + $scope.search
            }
          }, {
            lastName: {
              'contains': "" + $scope.search
            }
          }
        ]
      };
      PROFILE.find(query2).populate("appuserId").exec(function(err, data) {
        var l, userExists;
        doReset();
        if (err) {
          return console.log(err);
        } else if (data.length) {
          l = $scope.users.length;
          if (l > 0) {
            userExists = $scope.users.map(function(e) {
              return e.id;
            });
          }
          return data.forEach(function(user) {
            var appuser;
            appuser = angular.copy(user.appuserId);
            appuser.profileId = angular.copy(user);
            delete appuser.profileId.appuserId;
            if (!l || (userExists.indexOf(appuser.id)) === -1) {
              return $scope.users.push(appuser);
            }
          });
        }
      });
    }
  };
});

app.config([
  '$resourceProvider', function($resourceProvider) {
    return $resourceProvider.defaults.stripTrailingSlashes = false;
  }
]);

app.factory('ScopeFactory', [
  '$resource', function($resource) {
    return $resource('/scope/:id', {
      id: '@id'
    });
  }
]);

app.factory('AdminFactory', [
  '$resource', function($resource) {
    return $resource('/admin/:id', {
      id: '@id'
    });
  }
]);

common_methods = {
  list: {
    method: "GET",
    params: {
      idAction: "list"
    },
    isArray: true
  },
  find: {
    method: "GET",
    params: {
      idAction: "find"
    },
    isArray: false,
    cache: true
  },
  update: {
    method: "PUT",
    params: {
      idAction: "update"
    },
    isArray: false
  },
  create: {
    method: "POST",
    params: {
      idAction: "create"
    },
    isArray: false
  },
  remove: {
    method: "DELETE",
    params: {
      idAction: "remove"
    },
    isArray: false
  }
};

//# sourceMappingURL=superCtrl.js.map
