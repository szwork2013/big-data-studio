'use strict'

angular.module 'bigDataStudioApp'
.controller 'DataflowsCtrl', ($scope, $http) ->
  $scope.dataflows = []
  $scope.newDataflow = {}

  $http.get '/api/dataflows'
  .success (dataflows) ->
    $scope.dataflows = dataflows

  $scope.createDataflow = (form) ->
    $scope.submitted = true
    if form.$valid
      console.log "ScriptController-", $scope.newDataflow.name
      dataflow = { name: $scope.newDataflow.name, description: 'description', nodes: [], edges: [] }
      $http.post '/api/dataflows', dataflow
      .success (dataflow) ->
        console.log "successfully saved to REST!"
        $scope.dataflows.push dataflow
        $scope.newDataflow = {}
        $scope.submitted = false
  undefined
