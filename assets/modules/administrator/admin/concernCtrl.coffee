



app.controller 'ConcernCtrl', (ApiObject, $scope, $timeout, $http, $mdSidenav, $mdUtil, $log, $resource, ScopeFactory, AdminFactory, ConcernFactory,StatusFactory) ->
  $scope.scopes = []
  $scope.users = []
  $scope.userSearch = ''
  $scope.search = ''
  $scope.scopes = []

  $scope.addConcernForm = {}
  $scope.selectedScope = null
  $scope.editConcernForm = {}
  $scope.selected = false

  $scope.concerns = []
  $scope.addStatusForm = {}
  $scope.editStatusForm = {}
  $scope.statuses = []

  $scope.chooseStatus = false




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
    $scope.addConcernForm.name =''
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


  $scope.toAddConcern = (event, err) ->
    if err
      console.log err
      return

    $scope.chooseStatus = false
    $scope.toEdit = false

    $scope.toggleRight()

  $scope.addConcern = (event, err) ->

    if err
      console.log err
      return



    newConcern =
      name: $scope.addConcernForm.name,
      scopeId: $scope.selectedScope.id


    console.log newConcern

    saveConcern = ConcernFactory.save(
      newConcern,
      (successRes) ->
        $scope.close()
        $scope.addConcernForm = {}
        $scope.fillConcernList()
        #console.log successRes
      ,
      (err) ->
        console.log err

    )

  $scope.deleteConcern = (event, err) ->
    console.log "going to delete you ...."
    return





  $scope.toEditConcern = (concern) ->


    $scope.editConcernForm.name = concern.name
    $scope.toEdit = concern
    $scope.chooseStatus = false

    $scope.toggleRight()

    #inject view for 'edit scope' form

    return


  $scope.editConcern = (event, err) ->
    if err
      console.log err
      return

    # console.log event
    # console.log err

    updateConcern =
      name: $scope.editConcernForm.name


    concernId = $scope.toEdit.id

    scopeId = $scope.selectedScope.id
    newScope = $scope.editScopeForm
    ConcernFactory.get { id: concernId }, (saveConcern) ->
      saveConcern.name = updateConcern.name
      saveConcern.$save ()->
        $scope.fillConcernList()

        $scope.close()
        console.log "updated!!"


        $scope.toEdit = false
        $scope.editScopeForm = {}

    return


  $scope.selectScope = (scope) ->
    $scope.selected = true
    $scope.selectedScope = scope
    #console.log 'selected scope : ' + $scope.selectedScope.name
    $scope.defaultStatus = scope.defaultStatus
    $scope.fillConcernList()
    $scope.fillStatusList()
    return

  $scope.fillConcernList = () ->

    test = ScopeFactory.get(
      {id: $scope.selectedScope.id},
      (successRes) ->
        $scope.selectedScope.concerns = test.concerns

        return
    )

    return

  $scope.toAddStatus = (event, err) ->
    if err
      console.log err
      return
    $scope.chooseStatus = true
    $scope.toEditStat = false

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

  $scope.setDefaultStatus = (defaultStatus) ->
    console.log defaultStatus
    scopeId = $scope.selectedScope.id
    ScopeFactory.get {id: scopeId}, (saveScope) ->
      saveScope.defaultStatus = defaultStatus
      saveScope.$save (success) ->
        console.log success
        $scope.selectedScope = success
        $scope.fillScopeList()


    return

  $scope.deleteStatus = (event, err) ->
    console.log "going to delete you ...."
    return





  $scope.toEditStatus = (status) ->


    $scope.editStatusForm.name = status.name
    $scope.toEdit = status
    $scope.chooseStatus = true
    $scope.toEditStat = true

    $scope.toggleRight()


    return


  $scope.editStatus = (event, err) ->
    if err
      console.log err
      return

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

  $scope.fillStatusList = () ->

    test = ScopeFactory.get(
      {id: $scope.selectedScope.id},
      (successRes) ->
        $scope.selectedScope.status = test.status

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
