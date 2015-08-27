



app.controller 'StatusCtrl', (ApiObject, $scope, $timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, StatusFactory) ->
  $scope.scopes = []
  $scope.users = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.scopes = []

  $scope.addStatusForm = {}
  $scope.selectedScope = null
  $scope.editStatusForm = {}
  $scope.selected = false

  $scope.statuses = []




  #=================================

  # $scope.activeUser = "john"
  $http.get "/session/check"
  .success (user)->
    #$scope.activeUser = user.appuser
    userId = user.appuser
    scopeAdministered = []
    administer = AdminFactory.query(
      {userId: userId},
      (successRes) ->
        #console.log administer
        administer.forEach (admin, i) ->
          scopeAdministered.push admin.scopeId
        $scope.scopes = scopeAdministered
      ,
      (errRes) ->
        console.log errRes
    )

    return


  USER = new ApiObject "appuser"
  PROFILE = new ApiObject "profile"
  COMPANY = new ApiObject "company"
  APPS = new ApiObject "token"
  USERROLE = new ApiObject "userrole"


  $scope.showActive = () ->
    # console.log $cookies.getAll()

    return

  buildToggler = (navID) ->
    $scope.addStatusForm.name =''
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


  $scope.toAddStatus = (event, err) ->
    if err
      console.log err
      return

    # console.log event
    # console.log err
    # $scope.addScopeForm.name = ''
    $scope.toEdit = false
    $scope.toggleRight()

  $scope.addStatus = (event, err) ->

    if err
      console.log err
      return



    newStatus =
      name: $scope.addStatusForm.name,
      scopeId: $scope.selectedScope.id



    console.log newStatus

    saveStatus = StatusFactory.save(
      newStatus,
      (successRes) ->
        # $scope.statuses.push newStatus
        $scope.close()
        $scope.addStatusForm = {}
        $scope.fillStatusList()
        console.log successRes
      ,
      (err) ->
        console.log err


    )

  $scope.deleteStatus = (event, err) ->
    console.log "going to delete you ...."
    return





  $scope.toEditStatus = (status) ->


    $scope.editStatusForm.name = status.name
    $scope.toEdit = status

    $scope.toggleRight()

    #inject view for 'edit scope' form

    return


  $scope.editStatus = (event, err) ->
    if err
      console.log err
      return

    # console.log event
    # console.log err

    updateStatus =
      name: $scope.editStatusForm.name


    statusId = $scope.toEdit.id

    scopeId = $scope.selectedScope.id
    newScope = $scope.editScopeForm
    StatusFactory.get { id: statusId }, (saveStatus) ->
      saveStatus.name = updateStatus.name
      saveStatus.$save ()->
        $scope.fillStatusList()

        $scope.close()
        console.log "updated!!"


        $scope.toEdit = false
        $scope.editScopeForm = {}

    return


  $scope.selectScope = (scope) ->
    $scope.selected = true
    $scope.selectedScope = scope
    #console.log 'selected scope : ' + $scope.selectedScope.name
    $scope.fillStatusList()
    return

  $scope.fillStatusList = () ->
    # console.log 'in fillStatusList'
    #console.log $scope.selectedScope # check selected scope
    test = ScopeFactory.get(
      {id: $scope.selectedScope.id},
      (successRes) ->
        $scope.selectedScope.status = test.status
        # $scope.selectedScope.statuses.forEach (status, i) ->
        #   $scope.statuses.push status

        #console.log $scope.adminIds #list of admin ids of scopes for validation purposes
        return
    )



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
