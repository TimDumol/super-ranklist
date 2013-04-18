"use strict"

module = angular.module 'ranklist.auth', [

]

module.service 'CurrentUser', ['$http', ($http) ->
  data = null
  service = {
    data: -> data
    loggedIn: -> data?
    # Load from localStorage
    load: -> data = angular.fromJson(localStorage['userData']) ? {}
    # Load from /api/session
    loadRemote: ->
      $http.get('/api/session').success (user) ->
        data = user
        service.save()
      .error (err) ->
        data = null
        service.save()
    set: (user) ->
      data = user
      service.save()
    save: -> localStorage['userData'] = angular.toJson(data)
  }
  service.load()
  service
]

module.controller 'SessionCtrl', ['$scope', '$http', 'CurrentUser', ($scope, $http, CurrentUser) ->
  $scope.CurrentUser = CurrentUser
  $scope.logIn = ->
    email = prompt('Email')
    password = prompt('Password')
    $http.post('/api/session',
      email: email
      password: password
    ).success (user) ->
      console.log 'Success', user
      CurrentUser.set user
    .error (err) ->
      console.log 'Failure', err
      CurrentUser.set null
  $scope.logOut = ->
    $http.delete('/api/session').success (user) ->
      console.log 'Success'
      CurrentUser.set null
    .error (err) ->
      console.log 'Error!'
      CurrentUser.set null

  CurrentUser.loadRemote()
]
