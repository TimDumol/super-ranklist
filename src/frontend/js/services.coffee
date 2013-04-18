module = angular.module 'ranklist.services', [

]

module.service 'Notify', ['$window', ($window) ->
  $window.toastr
]

module.service 'LoadingNotification', ['Notify', (Notify) ->
  notification = null
  loading_ids = {}
  n_loading = 0
  service = {
    loading: (id, message = 'Loading...') ->
      unless loading_ids[id]
        loading_ids[id] = true 
        ++n_loading
      unless notification?
        notification = Notify.info(message, null, timeOut: 0)
    done: (id) ->
      if loading_ids[id]
        loading_ids[id] = false
        --n_loading
      if n_loading == 0
        notification.remove()
        notification = null
    isLoading: notification?
  }
]
