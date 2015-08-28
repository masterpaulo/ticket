



app.controller 'EmployeeCtrl', (ApiObject, $scope, $filter,$timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, AlertFactory, ReceiverFactory) ->

  # $scope.predicate = 'createdAt'
  # $scope.reverse = true
  # $scope.order = (predicate) ->
  #   $scope.reverse = if $scope.predicate == predicate then !$scope.reverse else false
  #   $scope.predicate = predicate


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
    newRequest.statusId = $scope.selectedScope.defaultStatus
    newRequest.userId = $scope.userId

    alertReceivers = []
    $scope.selectedScope.admins.forEach (el, i) ->
      alertReceivers.push {userId : el.userId}
    

    newAlert = {
      type: 'request',
      message: 'New Request : '+newRequest.title,
      userId: $scope.userId
      receivers: alertReceivers
    }

    #newRequest.alerts = newAlert # shortcut .. but no
    console.log "receivers"
    console.log alertReceivers
    console.log "alert"
 
    console.log newAlert
    console.log "request"
    console.log newRequest

    

    saveRequest = RequestFactory.save(
      newRequest,
      (requestData) ->
        console.log requestData
        $scope.fillRequestList()
        $scope. addRequestForm = {}
        newAlert.requestId = requestData.id
        saveAler = AlertFactory.save(
          newAlert,
          (alertData) ->
            console.log alertData

        )

        $scope.close()
      ,
      (err) ->
        console.log err
    )





  $scope.toViewRequest = (event, err) ->
    if err
      console.log errRes
      return


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




  orderBy = $filter('orderBy')
  # $scope.requests = Request
  $scope.order = (predicate, reverse) ->
    $scope.requests = orderBy($scope.requests, predicate, reverse)

  # $scope.order('createAt',false)



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


app.factory 'AlertFactory' , [
  '$resource'
  ($resource) ->
    $resource '/alert/:id', {id:'@id'} ,
]

app.factory 'ReceiverFactory' , [
  '$resource'
  ($resource) ->
    $resource '/receiver/:id', {id:'@id'} ,
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
