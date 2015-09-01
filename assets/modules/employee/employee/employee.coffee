




app.controller 'EmployeeCtrl', (ApiObject, $scope, $filter,$timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, CommentFactory, AlertFactory, ReceiverFactory) ->

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
  $scope.comments = CommentFactory.query()

  $scope.selectedScope = {}
  $scope.scopeConcerns = []

  $scope.addRequestForm = {}
  $scope.addCommentForm = {}

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

    $scope.fillAlertList()

    return





  buildToggler = (navID) ->
    debounceFn = $mdUtil.debounce((->
      $mdSidenav(navID).toggle().then ->
        $log.debug 'toggle ' + navID + ' is done'
        # console.log $scope.userId
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
      {userId:  $scope.userId, viewed:false },
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
    console.log 'addrequest'


    if err
      console.log err
      return

    # set all other data for new request
    newRequest = $scope.addRequestForm
    newRequest.statusId = $scope.selectedScope.defaultStatus
    newRequest.userId = $scope.userId

    # get all the receivers of the alert (usually admins)
    alertReceivers = []
    $scope.selectedScope.admins.forEach (el, i) ->
      alertReceivers.push {userId : el.userId}

    # set new alert data of the new request
    newAlert = {
      type: 'request',
      message: 'New Request : '+newRequest.title,
      userId: $scope.userId
      receivers: alertReceivers
    }


    # create request
    saveRequest = RequestFactory.save(
      newRequest,
      (requestData) ->
        console.log requestData
        $scope.fillRequestList()
        $scope. addRequestForm = {}

        #get new reqeustId
        newAlert.requestId = requestData.id

        #create alert
        saveAlert = AlertFactory.save(
          newAlert,
          (alertData) ->
            console.log alertData

        )

        $scope.close()
      ,
      (err) ->
        console.log err
    )

  $scope.onlyUnique = (value, index, self) ->
    return self.indexOf(value) == index;


  $scope.uniqueId = () ->
    $scope.allCommentedId = []
    angular.forEach($scope.comments, (value,key) ->
      $scope.allCommentedId.push JSON.stringify value.userId
    )
    # console.log $scope.allCommentedId
    uniqueId = $scope.allCommentedId.filter($scope.onlyUnique)
    $scope.allCommentedId = []

    uniqueId

  $scope.AllNames = () ->
    $scope.allNames = []

    uniqueId = $scope.uniqueId()
    angular.forEach(uniqueId, (value,key) ->
      userId = value

      USER.find({id:userId})
      .populate('profileId')
      .exec (err,data) ->
        if data

          name = data[0].profileId.firstName + " " + data[0].profileId.lastName
          appuserId = data[0].profileId.appuserId

          $scope.allNames.push({userId: appuserId, name: name})
          $scope.Names = $scope.allNames

          # a = true

    )
    $scope.allNames = []
    $scope.Names


      # console.log value
  $scope.searchUserExist = (nameKey, myArray) ->


    # console.log 'searchUserExist ni'
    i = 0
    while i < myArray.length
      if myArray[i].userId == nameKey
        return myArray[i]
      i++
    return

  $scope.addUsertoExist = (userId) ->
    # $scope.allNames = []

    # console.log 'addUsertoExist'
    USER.find(userId)
    .populate('profileId')
    .exec (err,data) ->
      if data
        $scope.name = data[0].profileId.firstName + " " + data[0].profileId.lastName
        # console.log data[0].profileId.firstName + " " +
        #  # $scope.Names = $scope.allNames
        # console.log name
        console.log $scope.name

    $scope.name




  $scope.allUsers = () ->

    # console.log 'ALLUSERS'
    # console.log $scope.selectedRequest.comments

    $scope.AllNames()

    # $scope.searchUserExist()
    $scope.selectedRequest.comments.forEach (value, key) ->
      resultObject = $scope.searchUserExist(value.userId, $scope.Names);
      # console.log resultObject.name
      $scope.selectedRequest.comments[key].name = resultObject.name




    # console.log $scope.selectedRequest.comments




  $scope.toViewRequest = (event, err) ->
    if err
      console.log errRes
      return


    $scope.toView = true
    $scope.allUsers()


    $scope.toggleRight()

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


  $scope.addComment = () ->


    $scope.userId

    newComment = $scope.addCommentForm
    newComment.userId = $scope.userId
    newComment.requestId = $scope.selectedRequest.id

    # console.log "showing selected request"
    # console.log $scope.selectedRequest.scopeId

    newAlert = {}

    scopeId = $scope.selectedRequest.scopeId.id

    scopeObj = ScopeFactory.get(
      {id:scopeId},
      (success) ->
        # console.log success
        alertReceivers = []
        success.admins.forEach (el, i) ->
          alertReceivers.push {userId : el.userId}




        newAlert = {
          type: 'comment',
          message: 'New comment : '+$scope.selectedRequest.title,
          userId: $scope.userId
          requestId: newComment.requestId
          receivers: alertReceivers

        }

        saveComment = CommentFactory.save(
          newComment,
          (success) ->
            console.log "added comment"
            # console.log 'ZZZZ' + JSON.stringify success
            resultObject = $scope.searchUserExist(newComment.userId, $scope.Names);
            # console.log 'MAO NI ANG RESULTOBJECT'+resultObject.length
            if resultObject
              console.log 'IF'
              # console.log resultObject.name
              success.name = resultObject.name

            else
              console.log 'ELSE'
              newName = $scope.addUsertoExist(newComment.userId);
              # console.log 'this is in the savecomment'+resultObject
              success.name = newName
            # success.name = 'gerald'
            $scope.selectedRequest.comments.push success
            console.log 'THIS IS YOUR NAME'+ JSON.stringify $scope.selectedRequest.comments
            # $scope.selectedRequest.comments.name = 'gerald'

            # console.log $scope.selectedRequest.comments

            $scope.addCommentForm = {}
            saveAlert = AlertFactory.save(
              newAlert,
              (alertData) ->
                # console.log alertData
            )
          ,
          (err) ->
            # console.log err

        )
        # console.log newAlert

        return
      ,
      (err) ->
        # console.log err
        return
    )



    return




  orderBy = $filter('orderBy')
  # $scope.requests = Request
  $scope.order = (predicate, reverse) ->
    $scope.requests = orderBy($scope.requests, predicate, reverse)

  # $scope.order('createAt',false)


  init = () ->




  init();

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
