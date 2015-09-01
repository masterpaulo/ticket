




app.controller 'EmployeeCtrl', (ApiObject, $scope, $filter,$timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, CommentFactory, AlertFactory, ReceiverFactory, ConcernFactory, StatusFactory) ->



  $scope.users = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.requests = []
  $scope.alerts = []
  $scope.scopes = ScopeFactory.query( {limit: 0}, (data)->
    data.forEach (scope) ->
      $scope.filteredScopeIds.push scope.id


    # console.log $scope.filteredScopeIds
  )
  $scope.concerns = ConcernFactory.query( {limit: 0}, (data) ->
    $scope.filteredConcerns = data
    data.forEach (concern) ->
      $scope.filteredConcernIds.push concern.id
  )
  $scope.statuses = StatusFactory.query( {limit: 0}, (data) ->
    $scope.filteredStatuses = data
    data.forEach (status) ->
      $scope.filteredStatusIds.push status.id
  )


  $scope.selectedScope = {}
  $scope.scopeConcerns = []

  $scope.addRequestForm = {}
  $scope.addCommentForm = {}

  $scope.selectedRequest = null
  $scope.editScopeForm = {}
  $scope.selected = false
  $scope.userId = ''

  $scope.reqListLoaded = false
  $scope.namesLoaded = false
  $scope.oops = false

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
        #$scope.requests.push requestData ### make this work
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
    $scope.reqListLoaded = false
    $scope.namesLoaded = false

    requests = RequestFactory.query(
      {userId: $scope.userId},
      (success) ->
        #$scope.requests = requests
        console.log requests
        reqs = requests.map (req) ->
          user = req.userId
          PROFILE.find({appuserId:user})
          .exec( (err,data) ->
            $scope.namesLoaded = false

            if err
              console.log err
              $scope.oops = true
              return
            name = data[0].firstName + " " + data[0].lastName
            req.name = name
            comments = req.comments.map (comment) ->
              user = comment.userId
              PROFILE.find({appuserId:user})
              .exec( (err, data) ->
                # console.log data
                $scope.namesLoaded = false

                if err
                  console.log err
                  $scope.oops = true
                  return
                comment.name = data[0].firstName + " " + data[0].lastName
              ).then () ->
                #console.log "finished loading comment names"
                $scope.namesLoaded = true
            

              return comment
            req.comments = comments
            return 
          ).then () ->
            console.log "this"
            return
          return req


        $scope.requests = reqs
        console.log reqs
        $scope.requests.reverse()
        $scope.reqListLoaded = true
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

    commenter = ""

    PROFILE.find({appuserId:$scope.userId})
    .exec (err, data) ->
      commenter = data[0].firstName + " " + data[0].lastName

      saveComment = CommentFactory.save(
        newComment,
        (success) ->
          console.log "added comment"
          console.log success
          success.name = commenter
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

  $scope.filteredScopeIds = []
  $scope.filterScopeBox = []
  $scope.filterScopeBox[0] = true
  $scope.filteredScopeIds[0] = 0


  $scope.filteredConcernIds = []
  $scope.filterConcernBox = []
  $scope.filterConcernBox[0] = true
  $scope.filteredConcernIds[0] = 0

  $scope.filteredStatusIds = []
  $scope.filterStatusBox = []
  $scope.filterStatusBox[0] = true
  $scope.filteredStatusIds[0] = 0

  $scope.filterScope = (scope) ->
    #console.log $scope
    # console.log this.scope
    if scope == 0
      #console.log this
      if this.filterScopeBox[0] == true
        $scope.filteredScopeIds = $scope.scopes.map (scope) ->
          $scope.filterScopeBox[scope.id] = false
          return scope.id
      else
        $scope.scopes.map (scope) ->
          $scope.filterScopeBox[scope.id] = false
        $scope.filteredScopeIds = []
      # return
    else

      $scope.filteredScopeIds = [] if this.filterScopeBox[0] is true
      $scope.filterScopeBox[0] = false
      scopeId = this.scope.id
      if ($scope.filteredScopeIds.indexOf scopeId) > -1
        delete $scope.filteredScopeIds[ $scope.filteredScopeIds.indexOf scopeId ]
      else
        $scope.filteredScopeIds.push scopeId

    #console.log $scope.filteredScopeIds
    $scope.filteredConcerns  = $filter('concernFilter')($scope.concerns, $scope.filteredScopeIds)
    $scope.filteredStatuses = $filter('concernFilter')($scope.statuses, $scope.filteredScopeIds)
    $scope.filterConcernBox[0] = true
    $scope.filterStatusBox[0] = true

    $scope.filterConcern(0)
    $scope.filterStatus(0)
    return

  $scope.isScopeChecked = (scopeId) ->
    # scopeId = this.scope.id
    if ($scope.filteredScopeIds.indexOf scopeId) > -1
      return true
    return false



  $scope.filterConcern = (concern) ->
    #console.log $scope
    # console.log this.scope


    if concern == 0
      #console.log this
      if this.filterConcernBox[0] == true
        $scope.filteredConcernIds = $scope.filteredConcerns.map (concern) ->
          $scope.filterConcernBox[concern.id] = false
          return concern.id
      else
        $scope.filteredConcerns.map (concern) ->
          $scope.filterConcernBox[concern.id] = false
        $scope.filteredConcernIds = []
      # return
    else

      $scope.filteredConcernIds = [] if this.filterConcernBox[0] is true
      $scope.filterConcernBox[0] = false
      concernId = this.concern.id
      if ($scope.filteredConcernIds.indexOf concernId) > -1
        delete $scope.filteredConcernIds[ $scope.filteredConcernIds.indexOf concernId ]
      else
        $scope.filteredConcernIds.push concernId

    #console.log $scope.filteredConcernIds
    #console.log $scope.filterConcernBox

    


    return

  $scope.isConcernChecked = (concernId) ->
    # scopeId = this.scope.id
    if ($scope.filteredConcernIds.indexOf concernId) > -1
      return true
    return false

  $scope.filterStatus = (status) ->
    #console.log $scope
    # console.log this.scope


    if status == 0
      #console.log this
      if this.filterStatusBox[0] == true
        $scope.filteredStatusIds = $scope.filteredStatuses.map (status) ->
          $scope.filterStatusBox[status.id] = false
          return status.id
      else
        $scope.filteredStatuses.map (status) ->
          $scope.filterStatusBox[status.id] = false
        $scope.filteredStatusIds = []
      # return
    else

      $scope.filteredStatusIds = [] if this.filterStatusBox[0] is true
      $scope.filterStatusBox[0] = false
      statusId = this.status.id
      if ($scope.filteredStatusIds.indexOf statusId) > -1
        delete $scope.filteredStatusIds[ $scope.filteredStatusIds.indexOf statusId ]
      else
        $scope.filteredStatusIds.push statusId

    #console.log $scope.filteredStatusIds
    #console.log $scope.filterStatusBox

    


    return

  $scope.isStatusChecked = (statusId) ->
    # scopeId = this.scope.id
    if ($scope.filteredStatusIds.indexOf statusId) > -1
      return true
    return false





  #configurations


app.filter 'concernFilter', [ 
  () ->
    return (concerns, selectedScopeIds) ->
      tempConcerns = []
      selectedScopeIds.forEach (scopeId) ->
        concerns.forEach (concern) ->
          if(scopeId == concern.scopeId.id)
            tempConcerns.push concern

      return tempConcerns

]

app.filter 'requestScopeFilter', [ 
  () ->
    return (requests, selectedScopeIds) ->
      tempReqs = []
      selectedScopeIds.forEach (scopeId) ->
        requests.forEach (request) ->
          if(scopeId == request.scopeId.id)
            tempReqs.push request

      return tempReqs

]

app.filter 'requestConcernFilter', [ 
  () ->
    return (requests, selectedConcernIds) ->
      tempReqs = []
      selectedConcernIds.forEach (concernId) ->
        requests.forEach (request) ->
          if(concernId == request.concernId.id)
            tempReqs.push request

      return tempReqs

]

app.filter 'requestStatusFilter', [ 
  () ->
    return (requests, selectedStatusIds) ->
      tempReqs = []
      selectedStatusIds.forEach (statusId) ->
        requests.forEach (request) ->
          if(statusId == request.statusId.id)
            tempReqs.push request

      return tempReqs

]










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

app.factory 'StatusFactory' , [
  '$resource'
  ($resource) ->
    $resource '/status/:id', {id:'@id'} ,
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
