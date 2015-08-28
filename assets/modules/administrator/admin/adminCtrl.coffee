



app.controller 'AdminCtrl', (ApiObject, $scope, $timeout, $filter, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, CommentFactory, AlertFactory, ReceiverFactory) ->

  $scope.scopes = []
  $scope.comments = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.scopes = ScopeFactory.query();

  $scope.selectedScope = {}
  $scope.scopeStatuses = []

  $scope.selected = false

  $scope.addCommentForm = {}

  $scope.employeeNames = []
  $scope.adminIds = []
  $scope.userId = ""
  $scope.scopes = [];

#========================

  $scope.requests = []
  $scope.alerts = []




  $http.get "/session/check"
  .success (user)->
    userId = user.appuser
    $scope.userId = userId

    $scope.fillAlertList() #setup alerts if any

    scopeAdministered = []
    administer = AdminFactory.query(
      {userId: userId},
      (successRes) ->
        #console.log administer
        administer.forEach (admin, i) ->
          scopeAdministered.push admin.scopeId.id
        $scope.scopes = scopeAdministered
        $scope.fillRequestList()
        $scope.fillAlertList()
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


  $scope.fillAlertList = () ->
    userScopes = $scope.scopes
    $scope.alerts = []
    #console.log userScopes
    receive = ReceiverFactory.query(
      {userId:  $scope.userId, viewed:false },
      (success) ->
        # console.log "showing alerts received"
        # console.log receive
        $scope.alerts = []
        receive.forEach (el) ->
          $scope.alerts.push el
      ,
      (err) ->
        console.log err
    )
    return

  $scope.selectAlert = (alert) ->

    console.log alert
    receiverId = alert.id
    alertScopeId = alert.alertId.requestId

    reqI = $scope.requests.map (request) ->
      return request.id

    $scope.selectRequest $scope.requests[reqI.indexOf(alertScopeId)]


    
    ReceiverFactory.get {id: receiverId}, (saveReceiver) ->
      saveReceiver.viewed = true
      saveReceiver.$save () ->
        console.log "user has viewed the alert."
        $scope.fillAlertList()

    return

  $scope.fillRequestList = () ->
    #$scope.requests = RequestFactory.query();
    userScopes = $scope.scopes
    #console.log userScopes
    if userScopes.length < 1
      return 

    requests = RequestFactory.query(
      {scopeId:  userScopes },
      (success) ->
        #console.log requests

        requests.forEach (req, i) ->
          user = req.userId
          USER.find({id:user})
          .populate('profileId')
          .exec (err,data) ->
            #console.log data
            $scope.employeeNames[user] = data[0].profileId.firstName + " " + data[0].profileId.lastName
            return

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
        $scope.addAlert(request.id, "status")

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
        $scope.addAlert(newComment.requestId, "comment") #
        
      ,
      (err) ->
        console.log err

    )

    return



  $scope.addAlert = (requestId, type) ->
    

    newAlert = {}
    msg = if type=="status" then "Status changed : " else "New comment : "
    scopeId = $scope.selectedRequest.scopeId.id

    scopeObj = ScopeFactory.get(
      {id:scopeId},
      (success) ->
        console.log success
        alertReceivers = []
        alertReceivers.push {userId:$scope.selectedRequest.userId}
        success.admins.forEach (el, i) ->
          if el.userId != $scope.userId
            alertReceivers.push {userId : el.userId}



        newAlert = {
          type: type,
          message: msg+$scope.selectedRequest.title,
          userId: $scope.userId
          requestId: requestId
          receivers: alertReceivers
        }
        saveAlert = AlertFactory.save(
          newAlert,
          (alertData) ->
            console.log alertData
        )
        
        console.log newAlert

        return
      ,
      (err) ->
        console.log err
        return
    )




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
