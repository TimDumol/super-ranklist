module = angular.module 'ranklist.services', [

]

module.service 'Notify', ['$window', ($window) ->
  $window.toastr
]
