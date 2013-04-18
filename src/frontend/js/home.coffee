module = angular.module 'ranklist.home', [
  'ngGrid'
  'ranklist.auth'
]

module.controller 'HomeCtrl', ['$log', '$scope', 'CurrentUser', ($log, $scope, CurrentUser) ->
  $scope.profiles = [
    {
      id: '123123'
      name: 'John Doe'
      uva:
        rank: 1
        id: 1
        username: 'doe'
        n_solved: 3
        n_tries: 5
    }
    {
      id: '2332532'
      name: 'Jane Doe'
      uva:
        rank: 2
        id: 2
        username: 'dane'
        n_solved: 2
        n_tries: 3
    }
  ]

  defaultColumns = [
    {
      field: 'name'
      displayName: 'Name'
    }
    {
      field: 'uva.rank'
      displayName: 'UVa Rank'
    }
    {
      field: 'uva.id'
      displayName: 'UVa ID'
    }
    {
      field: 'uva.username'
      displayName: 'UVa Username'
    }
    {
      field: 'uva.n_solved'
      displayName: 'UVa # Solved'
    }
    {
      field: 'uva.n_tries'
      displayName: 'UVa # Tries'
    }
  ]

  adminColumns = _.map(defaultColumns, (def) ->
      def.enableCellEdit = true 
      def
  ).concat [
    {
      field: 'id'
      displayName: 'Save'
      cellTemplate:
        '''
        <div class="ngCellText" ng-class="col.colIndex()"><span ng-cell-text><button class="btn" ng-click="save(row.entity)"><i class="icon-save"></i> Save</button></span></div>
        '''
    }
    {
      field: 'id'
      displayName: 'Delete'
      cellTemplate:
        '''
        <div class="ngCellText" ng-class="col.colIndex()"><span ng-cell-text><button class="btn" ng-click="delete(row.entity)"><i class="icon-remove"></i> Delete</button></span></div>
        '''
    }
  ]

  $scope.columnSet = ->
    (if CurrentUser.loggedIn() then adminColumns else defaultColumns)

  $scope.profileGridOptions = {
    data: 'profiles'
    columnDefs: 'columnSet()'
    enableCellSelection: true
  }

]
