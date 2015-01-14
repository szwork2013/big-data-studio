'use strict'

angular.module 'bigDataStudioApp'
.controller 'DataflowCtrl', ($scope, $http) ->
  $scope.definitions = {}
  $scope.sections = []
  $scope.parameters = []

  $http.get '/api/sections'
  .success (sections)->
    $scope.sections = sections

  $http.get '/api/definitions'
  .success (definitions)->
    $scope.definitions = definitions

