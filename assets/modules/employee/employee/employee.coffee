




app.controller 'EmployeeCtrl', (ApiObject, $scope, $filter,$timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, CommentFactory, AlertFactory, ReceiverFactory, ConcernFactory) ->

  # $scope.predicate = 'createdAt'
  # $scope.reverse = true
  # $scope.order = (predicate) ->
  #   $scope.reverse = if $scope.predicate == predicate then !$scope.reverse else false
  #   $scope.predicate = predicate


  $scope.users = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.requests = []
  $scope.alerts = []
  $scope.scopes = ScopeFactory.query()
  $scope.concerns = ConcernFactory.query()

  $scope.selectedScope = {}
  $scope.scopeConcerns = []

  $scope.addRequestForm = {}
  $scope.addCommentForm = {}

  $scope.selectedRequest = null
  $scope.editScopeForm = {}
  $scope.selected = false
  $scope.userId = ''

  $scope.reqListLoading = true


  USER = new ApiObject "appuser"
  PROFILE = new ApiObject "profile"
  COMPANY = new ApiObject "company"
  APPS = new ApiObject "token"
  USERROLE = new ApiObject "userrole"



  $http.get "/session/check"
  .success (user)->
    $scope.userId = user.appuser
    $scope.userSession = user
    $scope.activeRole = user.active.roleId

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
    $scope.fillRequestList()
    $scope.fillAlertList()

    return





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


  $scope.fillAlertList = () ->
    $scope.alerts = []
    receive = ReceiverFactory.query(
      {userId:  $scope.userId, viewed:false , roleId:$scope.activeRole},
      (success) ->
        # console.log "showing alerts received"
        # console.log receive
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

    # set all other data for new request
    newRequest = $scope.addRequestForm
    newRequest.statusId = $scope.selectedScope.defaultStatus
    newRequest.userId = $scope.userId

    # create request
    saveRequest = RequestFactory.save(
      newRequest,
      (requestData) ->
        console.log requestData
        $scope.fillRequestList()
        $scope. addRequestForm = {}

        reqId = requestData.id
        $scope.selectedRequest = requestData

        $scope.addAlert(reqId, "request") 
        #$scope.toView = true
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
    $scope.reqListLoading = true

    requests = RequestFactory.query(
      {userId: $scope.userId},
      (success) ->
        #$scope.requests = requests
        console.log requests
        reqs = requests.map (req) ->
          user = req.userId
          PROFILE.find({appuserId:user})
          .exec (err,data) ->
            #console.log data
            # $scope.employeeNames[user] = data[0].profileId.firstName + " " + data[0].profileId.lastName
            # requests[i].name = data[0].profileId.firstName + " " + data[0].profileId.lastName
            name = data[0].firstName + " " + data[0].lastName
            req.name = name
            comments = req.comments.map (comment) ->
              user = comment.userId
              PROFILE.find({appuserId:user})
              .exec (err, data) ->
                # console.log data
                comment.name = data[0].firstName + " " + data[0].lastName



              return comment
            req.comments = comments
            return 

          return req


        $scope.requests = reqs
        $scope.requests.reverse()
        $scope.reqListLoading = false
      ,
      (err) ->
        console.log err

    )
    #$scope.requests.reverse()

    return

  $scope.selectRequest = (request) ->
    $scope.selected = true
    $scope.selectedRequest = request
    $scope.toViewRequest()
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
        if $scope.selectedRequest.comments
          $scope.selectedRequest.comments.push success
        $scope.addCommentForm = {}
        $scope.addAlert(newComment.requestId, "comment")
        
      ,
      (err) ->
        console.log err

    )

 

    return


  $scope.addAlert = (requestId, type) ->
    

    msg = ''
    scopeId = 0
    newAlert = {}

    if type=="request"
      msg = "New request : " 
      scopeId = $scope.selectedRequest.scopeId
    else
      msg = "New comment : " 
      scopeId = $scope.selectedRequest.scopeId.id


    console.log scopeId
    console.log "the scope id"
    console.log $scope.selectedRequest

    scopeObj = ScopeFactory.get(
      {id:scopeId},
      (success) ->
        console.log success
        alertReceivers = []
        #alertReceivers.push {userId:$scope.selectedRequest.userId , roleId:32}
        success.admins.forEach (el, i) ->
          alertReceivers.push {userId : el.userId, roleId:33}



        newAlert = {
          type: type,
          message: msg+$scope.selectedRequest.title,
          userId: $scope.userId,
          roleId: $scope.roleId,  #which is obviously 33
          requestId: requestId,
          receivers: alertReceivers,
        }

        console.log "showing new alert data"
        console.log newAlert
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

##################################################################################
            # SORTING AND FILTERING FUNCTIONS #
##################################################################################
  orderBy = $filter('orderBy')
  # $scope.requests = Request
  $scope.order = (predicate, reverse) ->
    $scope.requests = orderBy($scope.requests, predicate, reverse)

  # $scope.order('createAt',false)

  $scope.filteredScope = []
  $scope.filterScopeBox = []

  $scope.filterScope = (scope) ->
    # console.log this
    # console.log this.scope
    if scope == 0
      console.log this
      if this.selectAllScope == true
        $scope.filteredScope = $scope.scopes.map (scope) ->
          $scope.filterScopeBox[scope.id] = true
          return scope.id
      else
        $scope.scopes.map (scope) ->
          $scope.filterScopeBox[scope.id] = false
        $scope.filteredScope = []
      return
    scopeId = this.scope.id
    if ($scope.filteredScope.indexOf scopeId) > -1
      delete $scope.filteredScope[ $scope.filteredScope.indexOf scopeId ]
    else
      $scope.filteredScope.push scopeId

    console.log $scope.filteredScope
    return

  $scope.isScopeChecked = (scopeId) ->
    # scopeId = this.scope.id
    if ($scope.filteredScope.indexOf scopeId) > -1
      return true
    return false


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



app.factory 'ConcernFactory' , [
  '$resource'
  ($resource) ->
    $resource '/concern/:id', {id:'@id'} ,
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
