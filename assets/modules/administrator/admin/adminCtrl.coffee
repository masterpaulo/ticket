



app.controller 'AdminCtrl', (ApiObject, $scope, $timeout, $filter, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, RequestFactory, CommentFactory, AlertFactory, ReceiverFactory, ConcernFactory, StatusFactory) ->

  $scope.scopes = []
  $scope.comments = []
  $scope.userSearch = ''
  $scope.search = ''
  # $scope.scopes = ScopeFactory.query();
  # $scope.filterScopes = ScopeFactory.query( {limit: 0}, (data)->
  #   data.forEach (scope) ->
  #     $scope.filteredScopeIds.push scope.id


  #   # console.log $scope.filteredScopeIds
  # )
  # $scope.filterConcerns = ConcernFactory.query( {limit: 0}, (data) ->
  #   $scope.filteredConcerns = data
  #   data.forEach (concern) ->
  #     $scope.filteredConcernIds.push concern.id
  # )
  # $scope.filterStatuses = StatusFactory.query( {limit: 0}, (data) ->
  #   $scope.filteredStatuses = data
  #   data.forEach (status) ->
  #     $scope.filteredStatusIds.push status.id
  # )



  $scope.selectedScope = {}
  $scope.scopeStatuses = []

  $scope.selected = false
  $scope.reqListLoaded = false
  $scope.namesLoaded = false



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
    $scope.userSession = user
    $scope.activeRole = user.active.roleId

    $scope.fillAlertList() #setup alerts if any

    scopeAdministered = []
    administer = AdminFactory.query(
      {userId: userId},
      (successRes) ->
        #console.log administer
        scopes = []
        administer.forEach (admin, i) ->
          scopeAdministered.push admin.scopeId.id
          scopes.push admin.scopeId


        $scope.filterScopes = scopes
        $scope.filteredScopeIds = scopeAdministered

        $scope.filterConcerns = ConcernFactory.query( {scopeId:scopeAdministered}, (data) ->
          $scope.filteredConcerns = data
          data.forEach (concern) ->
            $scope.filteredConcernIds.push concern.id
        )
        $scope.filterStatuses = StatusFactory.query( {scopeId:scopeAdministered}, (data) ->
          $scope.filteredStatuses = data
          data.forEach (status) ->
            $scope.filteredStatusIds.push status.id
        )



        $scope.scopes = scopeAdministered
        $scope.fillRequestList()
        $scope.fillAlertList()
      ,
      (errRes) ->
        console.log errRes
    )


  $scope.test = () ->
    console.log "session user"
    console.log $scope.userSession
    return 



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
      {userId:  $scope.userId, viewed:false , roleId:$scope.activeRole},
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
    $scope.reqListLoaded = false
    $scope.namesLoaded = false


    userScopes = $scope.scopes
    #console.log userScopes
    if userScopes.length < 1
      return 

    requests = RequestFactory.query(
      {scopeId:  userScopes },
      (success) ->
        #console.log requests

        reqs = requests.map (req) ->
          user = req.userId
          USER.find({id:user})
          .populate('profileId')
          .exec (err,data) ->
            #console.log data
            # $scope.employeeNames[user] = data[0].profileId.firstName + " " + data[0].profileId.lastName
            # requests[i].name = data[0].profileId.firstName + " " + data[0].profileId.lastName
            name = data[0].profileId.firstName + " " + data[0].profileId.lastName
            req.name = name
            comments = req.comments.map (comment) ->
              user = comment.userId
              USER.find({id:user})
              .populate('profileId')
              .exec( (err, data) ->
                # console.log data
                comment.name = data[0].profileId.firstName + " " + data[0].profileId.lastName
              ).then () ->
                console.log "finished loading names"
                $scope.namesLoaded = true

              return comment
            req.comments = comments
            return 
          return req

        console.log "===================="
        console.log reqs
        
        $scope.requests = reqs
        $scope.requests.reverse()

        $scope.reqListLoaded = true
        
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
        alertReceivers.push {userId:$scope.selectedRequest.userId , roleId:32}
        success.admins.forEach (el, i) ->
          if el.userId != $scope.userId
            alertReceivers.push {userId : el.userId, roleId:33}



        newAlert = {
          type: type,
          message: msg+$scope.selectedRequest.title,
          userId: $scope.userId,
          roleId: $scope.roleId,  #which is obviously 33
          requestId: requestId,
          receivers: alertReceivers,
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
        $scope.filteredScopeIds = $scope.filterScopes.map (scope) ->
          $scope.filterScopeBox[scope.id] = false
          return scope.id
      else
        $scope.filterScopes.map (scope) ->
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
    $scope.filteredConcerns  = $filter('concernFilter')($scope.filterConcerns, $scope.filteredScopeIds)
    $scope.filteredStatuses = $filter('concernFilter')($scope.filterStatuses, $scope.filteredScopeIds)
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
