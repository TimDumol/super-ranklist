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

module.controller 'HomeCtrl', ['$log', '$scope', 'CurrentUser', 'Profile', '$dialog', 'Notify', '$http', '$q', 'LoadingNotification', ($log, $scope, CurrentUser, Profile, $dialog, Notify, $http, $q, LoadingNotification) ->
  allProblems = null
  LoadingNotification.loading 'problems'
  $http.get("#{uHuntURL}/p").success((problems) ->
    allProblems = problems
    LoadingNotification.done 'problems'
    loadProfiles()
  ).error((err) ->
    LoadingNotification.done 'problems'
    Notify.error 'Error loading the problem list'
  )
  updateRanks = ->
    if $scope.profiles?
      profiles = _.sortBy($scope.profiles[..], (x) ->
        if x.n_soved?
          -x.n_solved
        else
          10000000
      )
      for profile, idx in profiles
        profile.uva.rank = idx+1
  loadProfiles = ->
    LoadingNotification.loading 'profiles'
    Profile.query((profiles) ->
      for profile in profiles
        do (profile) ->
          if profile.uva.id?
            $http.get("#{uHuntURL}/subs/#{profile.uva.id}").
              success((data) ->
                subs = JSON.parse data.subs
                if subs.length
                  sorted = _.sortBy(subs, (x) -> x[4])
                  profile.uva.latest = new Date((+sorted[sorted.length-1][4])*1000)
                  for sub in subs
                    if sub[2] == 90 # AC
                      pid = sub[1]
                      prob = _.findWhere($scope.problems, id: pid)
                      if prob?
                        if _.indexOf(prob, profile.name) == -1
                          prob.solvers.push profile.name
                      else
                        probArr = _.find(allProblems, (x) -> x[0] == pid)
                        prob =
                          id: pid
                          number: probArr[1]
                          title: probArr[2]
                          dacu: probArr[3]
                          solvers: [profile.name]
                        $scope.problems.push prob
            )
            $http.get("#{uHuntURL}/ranklist/#{profile.uva.id}/0/0").
              success((data) ->
                data = data[0]
                profile.uva.global_rank = data.rank
                profile.uva.n_solved = data.ac
                profile.uva.n_tries = data.nos
                updateRanks()
              )
      $scope.profiles = profiles
      LoadingNotification.done 'profiles'
    , ->
      LoadingNotification.done 'profiles'
      Notify.error 'Error loading profiles.'
    )
  
  defaultColumns = [
    {
      field: 'name'
      displayName: 'Name'
    }
    {
      field: 'uva.global_rank'
      displayName: 'UVa Global Rank'
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
    {
      field: 'uva.latest'
      displayName: 'Latest Submission'
      cellFilter: 'date'
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

  # the set of columns displayed
  $scope.columnSet = ->
    (if CurrentUser.loggedIn() then adminColumns else defaultColumns)

  # Saves updates to a profile
  $scope.save = (profile) ->
    Profile.update profile, ->
      Notify.success 'Successfully saved updates.'
      loadProfiles()
    , ->
      Notify.error 'Error saving updates.'

  # Deletes a profile
  $scope.delete = (profile) ->
    Profile.delete {id: profile.id}, ->
      Notify.success 'Successfully deleted the profile.'
      loadProfiles()
    , ->
      Notify.error 'Error deleteing the profile.'


  $scope.problems = []

  $scope.profileGridOptions = {
    data: 'profiles'
    columnDefs: 'columnSet()'
    enableCellSelection: true
  }

  $scope.problemGridOptions = {
    data: 'problems'
    columnDefs: [
      {
        field: 'number',
        displayName: 'Number'
      }
      {
        field: 'title'
        displayName: 'Title'
      }
      {
        field: 'dacu'
        name: 'DACU'
      }
      {
        field: 'solvers.length'
        name: 'Internal DACU'
      }
      {
        field: 'solvers'
        name: 'Solvers'
      }
    ]
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
        Profile.save profile, ->
          Notify.success 'User successfully saved.'
          loadProfiles()
        , ->
          Notify.error 'Failed to save user'
      , (err) ->
        Notify.error err

]
