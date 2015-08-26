
app.factory "SUPER",[
  "$resource"
  ($r)->
    @methods = null
    @methods = angular.copy common_methods

    return $r "/:idAction:listAction/:id", {id:"@id"} , @methods
]
