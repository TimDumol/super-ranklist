module = angular.module 'ranklist.home', [
  'ngGrid'
  'ranklist.auth'
  'ranklist.resources'
  'ranklist.services'
]

# TODO: Make this into a service?
uHuntURL = 'http://uhunt.felix-halim.net/api'

module.controller 'AddProfileCtrl', ['dialog', '$scope', (dialog, $scope) ->
  $scope.uva = {}
  $scope.submit = ->
    dialog.close(
      name: $scope.name
      uva: $scope.uva
    )
]

module.controller 'HomeCtrl', ['$log', '$scope', 'CurrentUser', 'Profile', '$dialog', 'Notify', '$http', '$q', ($log, $scope, CurrentUser, Profile, $dialog, Notify, $http, $q) ->
  $scope.profiles = Profile.query()
  

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
    if def.field in ['name', 'uva.username']
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

  $scope.addProfile = ->
    d = $dialog.dialog(templateUrl: '/templates/add-profile.html', controller: 'AddProfileCtrl')
    d.open().then (params) ->
      $log.log params
      def = $q.defer()
      if params.uva.username?
        $http.get("#{uHuntURL}/uname2uid/#{params.uva.username}").success((id) ->
          params.uva.id = id
          def.resolve(params)
        ).error((err) ->
          def.reject("Error getting UVa ID. Perhaps it doesn't exist?")
        )
      else
        def.resolve(params)
      def.promise.then (profile) ->
        Profile.save profile: profile, ->
          Notify.success 'User successfully saved.'
        , ->
          Notify.error 'Failed to save user'
      , (err) ->
        Notify.error err

]
