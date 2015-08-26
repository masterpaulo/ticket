app.factory("SUPER", [
  "$resource", function($r) {
    this.methods = null;
    this.methods = angular.copy(common_methods);
    return $r("/:idAction:listAction/:id", {
      id: "@id"
    }, this.methods);
  }
]);

//# sourceMappingURL=superModel.js.map
