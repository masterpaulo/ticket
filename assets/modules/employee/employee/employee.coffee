




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
  $scope.userId = ''




  USER = new ApiObject "appuser"
  PROFILE = new ApiObject "profile"
  COMPANY = new ApiObject "company"
  APPS = new ApiObject "token"
  USERROLE = new ApiObject "userrole"



  $http.get "/session/check"
  .success (user)->
    #$scope.activeUser = user.appuser
    $scope.userId = user.appuser
    # $scope.userId = userId
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
        console.log $scope.userId
        return

      return
    ), 200)
    debounceFn

  $scope.toggleRight = buildToggler('right')

  $scope.close = ->

    $mdSidenav('right').close().then ->
      $log.debug 'close RIGHT is done'
      return
    $scope.showComment = false
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
    $scope.requests.reverse()
    return

  $scope.selectRequest = (request) ->
    $scope.selected = true
    $scope.selectedRequest = request
    $scope.toViewRequest()
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


  $scope.addComment = () ->

    newComment = $scope.addCommentForm
    newComment.userId = $scope.userId
    newComment.requestId = $scope.selectedRequest.id

    saveComment = CommentFactory.save(
      newComment,
      (success) ->
        console.log "added comment"
        console.log success
        $scope.selectedRequest.comments.push success
        $scope.addCommentForm = {}
        # $scope.toView =true
        #$scope.fillCommentList()
      ,
      (err) ->
        console.log err

    )
    console.log newComment

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

app.factory 'CommentFactory' , [
  '$resource'
  ($resource) ->
    $resource '/comment/:id', {id:'@id'} ,
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
