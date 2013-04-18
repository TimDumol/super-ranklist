"use strict"

module = angular.module 'ranklist.routes', [
  'ranklist.home'
  'ranklist.admin'
]

module.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when('/',
      templateUrl: '/templates/home.html'
      controller: 'HomeCtrl'
    ).when('/admin',
      templateUrl: '/templates/admin.html'
      controller: 'AdminCtrl'
    ).when('/404'
      templateUrl: '/templates/404.html'
    ).otherwise(
      redirectTo: '/404'
    )
]
