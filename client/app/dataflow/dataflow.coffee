'use strict'

angular.module 'bigDataStudioApp'
.config ($stateProvider) ->
  $stateProvider.state 'dataflow',
    url: '/dataflow/:id'
    templateUrl: 'app/dataflow/dataflow.html'
    controller: 'DataflowCtrl'
