



app.controller 'EmployeeCtrl', (ApiObject, $scope, $timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory) ->

  $scope.users = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.requests = []
  $scope.scopes = ScopeFactory.query()

  $scope.selectedScope = {}
  $scope.scopeConcerns = []

  $scope.addRequestForm = {}
  $scope.selectedRequest = null
  $scope.editScopeForm = {}
  $scope.selected = false
  $scope.userId = 0



  USER = new ApiObject "appuser"
  PROFILE = new ApiObject "profile"
  COMPANY = new ApiObject "company"
  APPS = new ApiObject "token"
  USERROLE = new ApiObject "userrole"



  $http.get "/session/check"
  .success (user)->
    #$scope.activeUser = user.appuser
    $scope.userId = user.appuser
    userId = user.appuser
    userRequests = []
    requests = RequestFactory.query(
      {userId: userId},
      (success) ->
        $scope.requests = requests
      ,
      (err) ->
        console.log err
    )
    


  

  buildToggler = (navID) ->
    debounceFn = $mdUtil.debounce((->
      $mdSidenav(navID).toggle().then ->
        $log.debug 'toggle ' + navID + ' is done'
        return
      return
    ), 200)
    debounceFn

  $scope.toggleRight = buildToggler('right')

  $scope.close = ->
    $mdSidenav('right').close().then ->
      $log.debug 'close RIGHT is done'
      return
    return

  $scope.selectScope = (scope) ->
    console.log scope
    $scope.selectedScope = scope
    $scope.scopeConcerns = scope.concerns
    return 

  $scope.toAddRequest = (event, err) ->
    if err
      console.log err
      return

    # console.log event
    # console.log err
    # $scope.addRequestForm.name = ''
    $scope.toView = false
    $scope.toggleRight()

  $scope.addRequest = (event, err) ->

    if err
      console.log err
      return

    #console.log $scope.addRequestForm
    newRequest = $scope.addRequestForm
    newRequest.statusId = {name: "new", scopeId:newRequest.scopeId}
    newRequest.userId = $scope.userId

    console.log newRequest

    saveRequest = RequestFactory.save(
      newRequest,
      (successRes) ->
        console.log successRes
        $scope.fillRequestList()
        $scope. addRequestForm = {}
        $scope.close()
      ,
      (err) ->
        console.log err
    )

    

  

  $scope.toViewRequest = (event, err) ->
    if err
      console.log errRes
      return
    
    $scope.editScopeForm.name = $scope.selectedRequest.name
    $scope.toView = true

    $scope.toggleRight()

    #inject view for 'edit scope' form

    return


  $scope.fillRequestList = () ->
    #$scope.requests = RequestFactory.query();
    requests = RequestFactory.query(
      {userId: $scope.userId},
      (success) ->
        $scope.requests = requests
      ,
      (err) ->
        console.log err
    )
    return

  $scope.selectRequest = (request) ->
    $scope.selected = true
    $scope.selectedRequest = request
    $scope.toViewRequest()
    return



  $scope.fillAdminList = () ->
    #console.log $scope.selectedRequest # check selected scope
    $scope.adminIds = []
    test = ScopeFactory.get(
      {id: $scope.selectedRequest.id},
      (successRes) ->
        $scope.selectedRequest.admins = test.admins
        $scope.selectedRequest.admins.forEach (admin, i) ->
          userId = admin.userId
          $scope.adminIds.push userId
          USER.find({id:userId})
          .populate('profileId')
          .exec (err,data) ->
            #console.log data
            if data.length > -1
              appuser = data[0].profileId
              $scope.selectedRequest.admins[i].name = appuser.firstName + " " + appuser.lastName
            return
        #console.log $scope.adminIds #list of admin ids of scopes for validation purposes
        return
    )
    

    

    return

  $scope.adminExist = (user) ->
    if ($scope.adminIds.indexOf user.id) > -1
      return true
    else
      return false

  $scope.addAdmin = (user, scope) ->
    console.log user.id
    console.log scope.id
    $scope.search = ""
    data = {
      scopeId: scope.id
      userId: user.id
    }
    #$scope.ggNames.push user.profileId.firstName
    AdminFactory.save(
      data,
      (successRes) ->
        console.log successRes
        $scope.fillAdminList()
        return
      ,
      (errRes) ->
        console.log errRes
        return
    )
    
    return


  $scope.deleteAdmin = (adminId) ->
    console.log "deleting admin : " + adminId
    console.log AdminFactory.delete({id:adminId},
      (successRes) ->
        $scope.fillAdminList()
      ,
      (errRes) ->
        console.log errRes
    )
    

    return
  $scope.searchUser = ->
    reset = false
    doReset = ->
        if !reset
            reset = true
            $scope.users = []
    if $scope.search.length > 3
        reset = false
        $scope.users = []

        query1   =
            or:[
                {
                    email:
                        'contains':"#{$scope.search}"
                }
                {
                    username:
                        'contains':"#{$scope.search}"
                }

            ]

        USER.find query1
        .populate "profileId"
        .exec (err,data)->
            doReset()
            if err
                console.log err
            else if data.length
                l = $scope.users.length
                if l > 0
                    userExists = $scope.users.map (e)->
                        return e.id
                data.forEach (user)->
                    $scope.users.push user if !l or (userExists.indexOf user.id) is -1

        query2 =
            or:[
                {
                    firstName:
                        'contains':"#{$scope.search}"
                }
                {
                    lastName:
                        'contains':"#{$scope.search}"
                }

            ]

        PROFILE.find query2
        .populate "appuserId"
        .exec (err,data)->
            doReset()
            if err
                console.log err
            else if data.length
                l = $scope.users.length
                if l > 0
                    userExists = $scope.users.map (e)->
                        return e.id
                data.forEach (user)->
                    appuser = angular.copy user.appuserId
                    appuser.profileId = angular.copy user
                    delete appuser.profileId.appuserId
                    $scope.users.push appuser if !l or (userExists.indexOf appuser.id) is -1
    return






  #configurations

app.config [
  '$resourceProvider',
  ($resourceProvider) ->
    $resourceProvider.defaults.stripTrailingSlashes = false
]

app.factory 'ScopeFactory' , [
  '$resource'
  ($resource) ->
    $resource '/scope/:id', {id:'@id'}
]

app.factory 'AdminFactory' , [
  '$resource'
  ($resource) ->
    $resource '/admin/:id', {id:'@id'} ,
]


app.factory 'RequestFactory' , [
  '$resource'
  ($resource) ->
    $resource '/request/:id', {id:'@id'} ,
]







common_methods =
  list:
    method: "GET"
    params:
      idAction:"list"
    isArray: true
  find:
    method: "GET"
    params:
      idAction: "find"
    isArray: false
    cache:true
  update:
    method: "PUT"
    params:
      idAction:"update"
    isArray: false
  create:
    method: "POST"
    params:
      idAction:"create"
    isArray: false
  remove:
    method: "DELETE"
    params:
      idAction:"remove"
    isArray: false
