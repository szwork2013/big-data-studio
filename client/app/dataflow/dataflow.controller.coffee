'use strict'

angular.module 'bigDataStudioApp'
.controller 'DataflowCtrl', ['$scope', '$http', '$stateParams', '$modal', ($scope, $http, $stateParams, $modal) ->
  $scope.definitions = {}
  $scope.sections = []
  $scope.parameters = []

  $http.get '/api/sections'
  .success (sections)->
    $scope.sections = sections

  $http.get '/api/definitions'
  .success (definitions)->
    $scope.definitions = definitions

  $http.get '/api/dataflows/' + $stateParams.id
  .success (graph)->
    $scope.graph = graph
    drawing = new FunctionBlockDiagram('drawing', 720, 800, $scope.definitions)
    console.log drawing, graph
    drawing.load graph
    window.saveDrawing2 = () ->
      graph = drawing.save()
      console.log "saveDrawing2 graph", graph
      $http.put '/api/dataflows/' + $stateParams.id, graph
      .success (graph) ->
        console.log "successfully saved to REST!"

    window.deleteFB = () ->
      drawing.deleteFB()

    window.chartFB = () ->
      selectedFB = drawing.selectedFB()
      console.log "chartFB script:" + $stateParams.id + " fb: " + selectedFB.fb_name
      console.log "scope", $scope
      $scope.blockName = selectedFB.fb_name
      modalInstance = $modal.open {templateUrl:'app/dataflow/edit/graphfb.html',scope:$scope, controller:'ModalInstance2Ctrl', size:"lg"}
      undefined

    window.describeFB = () ->
      selectedFB = drawing.selectedFB()
      console.log "selectedFB script:" + $stateParams.id + " fb: " + selectedFB.fb_name
      $http.get "/tmp/"+$stateParams.id+"_"+selectedFB.fb_name+".json"
      .success (data) ->
        console.log data
        $scope.gridOptions = {
          enableSorting: false,
          onRegisterApi: (gridApi) ->
            $scope.gridApi = gridApi;
        }
        console.log data.columns
        $scope.gridOptions.columnDefs = ({name: column, width: 150, enableSorting: false } for column in data.columns)
        $scope.gridOptions.data = data.data;
        console.log "gridOptions", $scope.gridOptions
        modalInstance = $modal.open {templateUrl: 'app/dataflow/edit/describefb.html', scope:$scope, controller:'ModalInstance2Ctrl', size:"lg"}

    window.executeDrawing = () ->
      graph = drawing.save()
      console.log "saveDrawing2 graph", graph
      $http.put "/api/dataflows/#{$stateParams.id}", graph
      .success (graph) ->
        console.log "successfully saved to REST!"
        $http.get "/api/dataflows/#{$stateParams.id}/run"
        .success (result) ->
          console.log "executeDrawing", result

    drawing.selectBlock = (blockName, blockDefinition, parameters) ->
      console.log parameters
      $scope.$apply () ->
        console.log "$scope.$apply"
        params = ({"name":parameter.name, "value":parameter.value} for parameter in parameters)
        console.log "params",params
        $scope.blockName = blockName
        $scope.blockDefinition = blockDefinition
        $scope.parameters = params
        $scope.editParam = (name) ->
          console.log "Calling Dialog.openModal", $scope.blockName, $scope.blockDefinition
          modalInstance = $modal.open {templateUrl:'app/dataflow/edit/parameters.html',scope:$scope, controller:'ModalInstanceCtrl'}
          modalInstance.result.then (result) ->
            console.log "result!", result
            console.log "saveParameters"
            for parameter in $scope.parameters
              if (parameter.name of result)
                console.log "update", parameter.name, "to", result[parameter.name]
                parameter.value = result[parameter.name]
              else
                console.log "not updated", parameter.name
            drawing.setParametersOnBlock $scope.blockName, result
          modalInstance.opened.then () ->
            console.log "opened!"

  $scope.editParam = () ->
    console.log "editParam"
]

angular.module 'bigDataStudioApp'
.controller 'ModalInstanceCtrl', ($scope, $modalInstance) ->

  console.log $scope.blockDefinition.parameters
  $scope.editParameters = ({name:p.name,value:p.value} for p in $scope.parameters)

  $scope.save = (form) ->
    console.log form
    d = {}
    d[p.name] = p.value for p in $scope.editParameters
    console.log "d", d
    $modalInstance.close(d)

  $scope.close = () ->
    $modalInstance.dismiss('cancel');

angular.module 'bigDataStudioApp'
.controller 'ModalInstance2Ctrl', ($scope, $modalInstance) ->

  console.log "ModalInstance2Ctrl"

  $scope.close = () ->
    $modalInstance.dismiss('cancel');
