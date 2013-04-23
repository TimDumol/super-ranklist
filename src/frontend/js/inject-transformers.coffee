angular.module("ranklist.injectTransformers", []).directive "injectTransformers", [->
  restrict: "A"
  require: "ngModel"
  priority: -1
  link: (scope, element, attr, ngModel) ->
    local = scope.$eval(attr.injectTransformers)
    throw "The injectTransformers directive must be bound to an object with two functions (`fromModel` and `fromElement`)"  if not angular.isObject(local) or not angular.isFunction(local.fromModel) or not angular.isFunction(local.fromElement)
    ngModel.$parsers.push local.fromElement
    ngModel.$formatters.push local.fromModel
]
