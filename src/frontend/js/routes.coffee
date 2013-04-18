"use strict"

module = angular.module 'ranklist.routes', [
  'ranklist.home'
]

module.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when('/',
      templateUrl: '/templates/home.html'
      controller: 'HomeCtrl'
    ).when('/404'
      templateUrl: '/templates/404.html'
    ).otherwise(
      redirectTo: '/404'
    )
]
