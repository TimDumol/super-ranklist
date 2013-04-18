module = angular.module 'ranklist.resources', [
  'ngResource'
]

module.factory 'Profile', ['$resource', ($resource) ->
  $resource('/api/profiles/:id')
]
