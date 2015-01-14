class Connector
  constructor: (fb, connector_name, isInput, x, y, radius, drawing) ->
    @connector_name = connector_name
    @fb = fb
    @x = x
    @y = y
    @isInput = isInput
    @radius = radius
    @visual = @createVisual(drawing, fb)

  createVisual: (drawing, fb) ->
    connector = new Kinetic.Circle({
      x: @x
      y: @y
      radius: @radius
      fill: 'black'
      name: @connector_name
      model: this
    });
    if !@isInput
      connector.on 'mousedown', (e) =>
        console.log "Connect mousedown"
        e.cancelBubble = true
        c = new Connection(this, null, drawing)
        drawing.interactionLayer.add c.visual
        drawing.latestElement = c
        drawing.updateConnectors()
        drawing.connectorLayer.visible true
        drawing.connectorLayer.draw();

      connector.on 'mousemove', () =>
        console.log "Connect mousemove"
        if drawing.latestElement?
          mousePos = drawing.stage.getPointerPosition()
          drawing.tool.mouseMove drawing.latestElement, mousePos.x ,mousePos.y
          drawing.interactionLayer.draw()

      connector.on 'mouseup', () =>
        console.log "surface up"
        drawing.connectorLayer.visible false

      connector.on 'mouseover', () ->
        document.body.style.cursor = 'pointer'
        this.setRadius(8)
        drawing.interactionLayer.draw()

      connector.on 'mouseout', () ->
        document.body.style.cursor = 'default'
        this.setRadius(6)
        drawing.interactionLayer.draw()

    connector

  move: (x, y) ->
    @visual.x x
    @visual.y y
    undefined

class FunctionBlock
  constructor: (fb_name, fb_definition, instance_parameters, x, y, drawing) ->
    @fb_name = fb_name
    @fb_definition = fb_definition
    @definition = drawing.functionBlockDefinitions[fb_definition]
    @parameters = @make_parameters(@definition.parameters, instance_parameters)
    @x = x
    @y = y
    @connectors = {}
    for connector in @definition.connectors
      height = if connector.isInput then 0 else @definition.height
      @connectors[connector.name] = new Connector(this, connector.name, connector.isInput, @definition.width/2, height, 6, drawing)
    @visual=@createVisual(drawing)

  createVisual: (drawing) ->
    rect = new Kinetic.Rect({
      x: 0,
      y: 0,
      name: 'rect'
      width: @definition.width,
      height: @definition.height,
      fill: @definition.fill,
      stroke: 'black',
      strokeWidth: 2
    });
    text = new Kinetic.Text({
      x: 0,
      y: 5,
      width: @definition.width,
      text: @fb_definition,
      fontSize: 18,
      fontFamily: 'Calibri',
      fill: 'black',
      align: 'center',
    });
    group = new Kinetic.Group({
      x: @x
      y: @y
      name: 'fb'
      draggable: true
      model: this
      fb_name: @fb_name
    })
    group.add rect, text
    for name, connector of @connectors
      group.add connector.visual
    fb = this
    group.on 'dragmove', () ->
      console.log "dragmove"
      fb.x = @x()
      fb.y = @y()
      drawing.updateConnections()
    group.on 'mousedown', () ->
      drawing.updateSelection(group)
    group.on 'mousemove', () ->
      drawing.doMove()
    group

  make_parameters: (definition_parameters, instance_parameters) ->
    parameters = []
    param_dict = {}
    for parameter in definition_parameters
      param = {name:parameter.name, value:parameter.default}
      parameters.push param
      param_dict[parameter.name] = param
    if instance_parameters
      for parameter in instance_parameters
        if parameter.name of param_dict
          param_dict[parameter.name].value = parameter.value
    parameters


  selected: (isSelected) ->
    v = @visual
    rect = v.find('.rect')[0]
    rect.setAttr('strokeWidth', if isSelected then 4 else 2)
    rect.draw()
    undefined

class Connection
  constructor: (from_connector, to_connector, drawing) ->
    console.log "new Connection", from_connector, to_connector
    @from_connector = from_connector
    @to_connector = to_connector
    @visual=@createVisual(drawing)

  calc_points: () ->
    from_block = @from_connector.fb
    x = @from_connector.x + from_block.x
    y = @from_connector.y + from_block.y
    x2 = x
    y2 = y
    if @to_connector
      to_block = @to_connector.fb
      x2 = @to_connector.x + to_block.x
      y2 = @to_connector.y + to_block.y
    [x, y, x2, y2]

  createVisual: (drawing) ->
    connector = new Kinetic.Line({
      points: @calc_points()
      stroke: 'black'
      strokeWidth: 2
      listening: false
      name: 'connection'
      model: this
    });
    connector

  update_visual: () ->
    @visual.points(@calc_points())
    undefined

class ConnectorTool
  mouseDown: (x,y) ->
    undefined
  mouseMove: (element, x,y) ->
    #console.log "ConnectorTool mouseMove", x, y
    v = element.visual
    x1 = v.points()[0]
    y1 = v.points()[1]
    v.points([x1,y1,x,y])
    #console.log v.points()

class FunctionBlockTool
  mouseDown: (x,y) ->
    new Kinetic.Rect({
      x: x,
      y: y,
      width: 0,
      height: 0,
      fill: '#FFD200',
      stroke: 'black',
      strokeWidth: 4,
      listening: false
    });
  mouseMove: (element, x,y) ->
    element.width x - element.x()
    element.height y - element.y()

class @FunctionBlockDiagram
  constructor: (containerId, width, height, functionBlockDefinitions) ->
    console.log "new FunctionBlockDiagram", functionBlockDefinitions
    @fbs = {}
    @connections = []
    @name = "Unknown"
    @stage = new Kinetic.Stage({
      container : containerId
      height    : height
      width     : width
    })
    defs = {}
    defs[fb.name] = fb for fb in functionBlockDefinitions
    @functionBlockDefinitions = defs
    @fromX = 0
    @fromY = 0
    @latestElement = null
    @currentSelection = null
    # Init the layers
    @backgroundLayer = new Kinetic.Layer()
    @interactionLayer = new Kinetic.Layer()
    @connectorLayer = new Kinetic.Layer()
    @connectorLayer.visible false
    @tool = new ConnectorTool()
    #$('#saveBtn').click (event) =>
    #  @save()
    @background = new Kinetic.Rect({
      x: 0
      y: 0
      width: width
      height: height
      fill: 'white'
      stroke: 'black'
      strokeWidth: 1
    })
    @interactionRect = new Kinetic.Rect({
      x: 0
      y: 0
      width: width
      height: height
      fill: 'white'
      stroke: null
      opacity: 0.5
    })
    @connectorRect = new Kinetic.Rect({
      x: 0
      y: 0
      width: width
      height: height
      fill: 'white'
      stroke: null
      opacity: 0.5
    })
    @interactionRect.on 'mousedown', () =>
      mousePos = @stage.getPointerPosition()
      @latestElement = @tool.mouseDown(mousePos.x,mousePos.y)
      if @latestElement
        @interactionLayer.add(@latestElement);
        @interactionLayer.draw();
    @interactionRect.on 'mousemove', () =>
      @doMove()
    @interactionRect.on 'mouseup', () =>
      console.log "surface up"
      @doUp()
    @connectorLayer.on 'mousemove', () =>
      @doMove()
    @connectorLayer.on 'mouseup', () =>
      console.log "surface up"
      @doUp()
    @backgroundLayer.add(@background)
    @interactionLayer.add(@interactionRect)
    @connectorLayer.add(@connectorRect)
    @stage.add(@backgroundLayer)
    @stage.add(@interactionLayer)
    @stage.add(@connectorLayer)
    self = this
    con = @stage.getContainer()
    con.addEventListener 'dragover', (e) =>
      e.preventDefault()
    con.addEventListener 'drop', (e) =>
      #console.log e.dataTransfer
      r = e.target.getBoundingClientRect();
      x = e.clientX-r.left
      y = e.clientY-r.top
      blk_type = e.dataTransfer.getData("Text")
      idx = 0
      loop
        idx +=1
        name = blk_type+idx.toString()
        break if not @constainsFbNamed name
      fb = new FunctionBlock(name, blk_type, null, x, y, self)
      console.log fb
      @fbs[name]=fb
      @interactionLayer.add(fb.visual)
      @interactionLayer.draw()

  constainsFbNamed: (name) ->
    if name of @fbs
        return true
    false

  fbNamed: (name) ->
    if name of @fbs
      return @fbs[name]
    null

  doDrop: () ->
    console.log("drop")

  updateConnections: () ->
    for connection in @connections
      connection.update_visual()
    @interactionLayer.draw()

  updateSelection: (sel) ->
    console.log "updateSelection", sel
    if @currentSelection
      fb = @currentSelection.getAttr('model')
      fb.selected(false)
    @currentSelection = sel
    fb = sel.getAttr('model')
    fb.selected(true)
    this.selectBlock fb.fb_name, fb.definition, fb.parameters

  updateConnectors: () ->
    fdb = this
    console.log("updateConnectors")
    @connectorLayer.destroyChildren()
    @connectorLayer.add(@connectorRect)
    for name, fb of @fbs
      fb_definition = fb.definition
      console.log "fb", fb
      for n, connector of fb.connectors
        console.log "connector", connector
        if connector.isInput
          inConnector = new Kinetic.Circle({
            x: fb.x+connector.x
            y: fb.y+connector.y
            radius: 6
            fill: 'red'
            #to_block: fb
            #to_connector: inC
            model: connector
          });
          self = this
          inConnector.on 'mouseover', () ->
            console.log "connector mouseover", this
            document.body.style.cursor = 'pointer'
            this.setRadius(8)
            this.draw()

          inConnector.on 'mouseout', () ->
            console.log "connector mouseout", this
            document.body.style.cursor = 'default'
            this.setRadius(6)
            this.draw()

          inConnector.on 'mouseup', () ->
#            console.log "connector mouseup", this
            self.latestElement.to_connector = this.getAttr('model')
#            console.log "latestElement", self.latestElement
            #fdb.interactionLayer.add self.latestElement.visual
            fdb.connections.push self.latestElement
            fdb.updateConnections()
            self.connectorLayer.visible false
            self.latestElement = null

#          console.log "inConnector", inConnector
          @connectorLayer.add(inConnector)




  doMove: () ->
    #console.log "doMove", @latestElement?
    if @latestElement?
      mousePos = @stage.getPointerPosition()
      @tool.mouseMove @latestElement, mousePos.x ,mousePos.y
      @interactionLayer.draw()

  doUp: () ->
    console.log "doUp"
    if @latestElement?
      # @latestElement.moveTo @drawingLayer
      v = @latestElement.visual
      v.off 'mouseup'
      v.off 'mousemove'
      v.remove()
      @latestElement=null;
      #@drawingLayer.draw()
      @interactionLayer.draw()
      @connectorLayer.visible false

  load: (drawing) ->
    #console.log "Load It"
    console.log "drawing", drawing
    @name = drawing.name
    @description = drawing.description
    @id = drawing._id
    @fbs = {}
    for node in drawing.nodes
      console.log "node", node
      fb = new FunctionBlock(node.name,node.definition,node.parameters,node.x,node.y,this)
      @fbs[node.name] = fb
      @interactionLayer.add(fb.visual)
    @connections = []
    for edge in drawing.edges
      console.log "edge", edge
      from_node = @fbs[edge.from_node]
      console.log "from_node", from_node
      from_connector = from_node.connectors[edge.from_connector]
      console.log "from_connector", from_connector
      to_node = @fbs[edge.to_node]
      console.log "to_node", to_node
      to_connector = to_node.connectors[edge.to_connector]
      console.log "to_connector", to_connector
      ed = new Connection(from_connector, to_connector, this)
      @connections.push ed
      @interactionLayer.add(ed.visual)
    #@updateConnectors()
    @interactionLayer.draw()


  setParametersOnBlock: (blockName, parameters) ->
    console.log "parameters", parameters
    fb = this.fbNamed(blockName)
    console.log fb
    if fb
      for parameter in fb.parameters
        console.log "parameter", parameter, parameter.name
        if parameter.name of parameters
          console.log "parameter.name", parameter.name, parameter.value, parameters[parameter.name]
          parameter.value = parameters[parameter.name]

  save: () ->
    console.log "Save It"
    nodes = ({ name: fb.fb_name, definition: fb.fb_definition, x: fb.x, y: fb.y, parameters: fb.parameters} for x, fb of @fbs)
    edges = []
    for connection in @connections
      from_connector = connection.from_connector
      from_block = from_connector.fb
      to_connector = connection.to_connector
      to_block = to_connector.fb
      edges.push { from_node: from_block.fb_name, from_connector: from_connector.connector_name, to_node: to_block.fb_name, to_connector: to_connector.connector_name }
    {_id: @id, name:@name, description:@description, nodes:nodes, edges:edges}

  deleteFB: () ->
    console.log "Delete FB"
    if @currentSelection
      console.log @connections
      fb = @currentSelection.getAttr('model')
      remove_connections = @connections.filter (item) -> item.from_connector.fb == fb or item.to_connector.fb == fb
      console.log "remove_connections", remove_connections
      for connection in remove_connections
          connection.visual.remove()
      @connections = @connections.filter (item) -> remove_connections.indexOf(item) < 0
      @currentSelection.remove()
      @currentSelection = null
      @interactionLayer.draw()

  selectedFB: () ->
    console.log "selectedFB"
    fb_name = null
    if @currentSelection
      fb_name = @currentSelection.getAttr('fb_name')
    {'fb_name': fb_name}

dragStart = (ev) ->
  ev.dataTransfer.effectAllowed='move'
  ev.dataTransfer.setData "Text", ev.target.getAttribute('data-item-name')
  ev.dataTransfer.setDragImage ev.target,0,0
  true

root = exports ? this
root.FunctionBlockDiagram = FunctionBlockDiagram
root.dragStart = dragStart
