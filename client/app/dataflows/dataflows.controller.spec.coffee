'use strict'

describe 'Controller: DataflowsCtrl', ->

  # load the controller's module
  beforeEach module 'bigDataStudioApp'
  DataflowsCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DataflowsCtrl = $controller 'DataflowsCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
