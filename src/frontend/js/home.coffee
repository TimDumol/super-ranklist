module = angular.module 'ranklist.home', []

module.controller 'HomeCtrl', ['$scope', ($scope) ->
  $scope.profiles = []
  $scope.addProfile = ->
    $scope.profiles.push
      name: 'John Doe'
      rank: 1
      uva:
        id: 1
        username: 'doe'
        problems_solved: 1
        num_tries: 1
]
