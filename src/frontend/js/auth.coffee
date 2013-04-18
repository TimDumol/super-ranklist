"use strict"

module = angular.module 'ranklist.auth', [
  'ui.bootstrap'
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

module.controller 'LoginCtrl', ['dialog', '$scope', '$http', 'CurrentUser', (dialog, $scope, $http, CurrentUser) ->
  $scope.submit = ->
    dialog.close(email: $scope.email, password: $scope.password)
]

module.controller 'SessionCtrl', ['$log', '$dialog', '$scope', '$http', 'CurrentUser', ($log, $dialog, $scope, $http, CurrentUser) ->
  $scope.CurrentUser = CurrentUser
  $scope.logIn = ->
    logInDialog = $dialog.dialog(
      templateUrl: '/templates/login.html'
      controller: 'LoginCtrl'
    )
    logInDialog.open().then (params) ->
      $http.post('/api/session',
        params
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
