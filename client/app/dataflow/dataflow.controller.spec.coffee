'use strict'

describe 'Controller: DataflowCtrl', ->

  # load the controller's module
  beforeEach module 'bigDataStudioApp'
  DataflowCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DataflowCtrl = $controller 'DataflowCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
