'use strict'

angular.module 'bigDataStudioApp'
.config ($stateProvider) ->
  $stateProvider.state 'dataflows',
    url: '/dataflows'
    templateUrl: 'app/dataflows/dataflows.html'
    controller: 'DataflowsCtrl'
