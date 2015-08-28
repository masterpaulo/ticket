



app.controller 'AdminCtrl', (ApiObject, $scope, $timeout, $filter, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, CommentFactory) ->

  $scope.scopes = []
  $scope.comments = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.scopes = []
  $scope.scopes = ScopeFactory.query();

  $scope.selectedScope = {}
  $scope.scopeStatuses = []

  $scope.selected = false

  $scope.addCommentForm = {}


  $scope.adminIds = []
  $scope.userId = ""
  $scope.scopes = [];

#========================

  $scope.requests = []


  $http.get "/session/check"
  .success (user)->
    #$scope.activeUser = user.appuser
    userId = user.appuser
    $scope.userId = userId
    scopeAdministered = []
    administer = AdminFactory.query(
      {userId: userId},
      (successRes) ->
        #console.log administer
        administer.forEach (admin, i) ->
          scopeAdministered.push admin.scopeId.id
        $scope.scopes = scopeAdministered
        $scope.fillRequestList()
      ,
      (errRes) ->
        console.log errRes
    )



  USER = new ApiObject "appuser"
  PROFILE = new ApiObject "profile"
  COMPANY = new ApiObject "company"
  APPS = new ApiObject "token"
  USERROLE = new ApiObject "userrole"



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


  $scope.fillRequestList = () ->
    #$scope.requests = RequestFactory.query();
    userScopes = $scope.scopes
    #console.log userScopes
    requests = RequestFactory.query(
      {scopeId:  userScopes },
      (success) ->
        #console.log requests
        $scope.requests = requests
        $scope.requests.reverse()
      ,
      (err) ->
        console.log err
    )
    return


  $scope.selectRequest = (request) ->
    $scope.selected = true
    $scope.selectedRequest = request
    $scope.selectScope request.scopeId
    $scope.toViewRequest()
    #console.log request
    return



  $scope.toViewRequest = (event, err) ->
    if err
      console.log errRes
      return

    #$scope.editScopeForm.name = $scope.selectedRequest.name
    $scope.toView = true
    # $scope.fillCommentList()
    $scope.toggleRight()

    #inject view for 'edit scope' form

    return



  $scope.selectScope = (scope) ->

    scopeObj = ScopeFactory.get(
      {id:scope.id},
      (success) ->

        $scope.selectedScope = scopeObj
        $scope.scopeStatuses = scopeObj.status

      ,
      (err) ->
        console.log err
    )

    return



  $scope.setStatus = (status, request) ->
    $scope.selectedRequest.statusId = status
    RequestFactory.get {id:request.id}, (saveRequest) ->

      saveRequest.statusId = status.id
      saveRequest.$save (success) ->
        $scope.selectedRequest = success
        $scope.fillRequestList()

        return
      return

    return

##   COMMENTS

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
        #$scope.fillCommentList()
      ,
      (err) ->
        console.log err
    )
    console.log newComment
    return


  # $scope.fillCommentList = () ->
  #   requestId = $scope.selectedRequest.id
  #   comments = CommentFactory.query(
  #     {requestId:  requestId },
  #     (success) ->
  #       $scope.comments = comments
  #     ,
  #     (err) ->
  #       console.log err
  #   )
  #   return

  orderBy = $filter('orderBy')
  # $scope.requests = Request
  $scope.order = (predicate, reverse) ->
    $scope.requests = orderBy($scope.requests, predicate, reverse)

  $scope.order('title',false)




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
