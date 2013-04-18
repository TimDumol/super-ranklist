"use strict"

module = angular.module 'ranklist.auth', [

]

module.service 'CurrentUser', ->
  data = null
  service = {
    data: -> data
    load: -> data = angular.fromJson(localStorage['userData']) ? {}
    save: -> localStorage['userData'] = angular.toJson(data)
  }
  service.load()
  service

module.controller 'SessionCtrl', ['$scope', 'CurrentUser', ($scope, CurrentUser) ->
  $scope.currentUser = CurrentUser
]
