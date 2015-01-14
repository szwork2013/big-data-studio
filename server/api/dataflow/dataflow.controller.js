'use strict';

var _ = require('lodash');
var Dataflow = require('./dataflow.model');
var exec = require('child_process').exec;

// Get list of dataflows
exports.index = function(req, res) {
  Dataflow.find(function (err, dataflows) {
    if(err) { return handleError(res, err); }
    return res.json(200, dataflows);
  });
};

// Get a single dataflow
exports.show = function(req, res) {
  Dataflow.findById(req.params.id, function (err, dataflow) {
    if(err) { return handleError(res, err); }
    if(!dataflow) { return res.send(404); }
    return res.json(dataflow);
  });
};

// Creates a new dataflow in the DB.
exports.create = function(req, res) {
  var newDataflow = req.body;
  newDataflow.owner = req.user.email;
  if(!newDataflow.nodes) {newDataflow.nodes=[];}
  if(!newDataflow.edges) {newDataflow.edges=[];}
  Dataflow.create(req.body, function(err, dataflow) {
    if(err) { return handleError(res, err); }
    return res.json(201, dataflow);
  });
};

// Updates an existing dataflow in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  var dataflowId = req.params.id;
  console.log("Update Dataflow");
  var updatedDataflow = req.body;

  Dataflow.findById(dataflowId, function (err, dataflow) {
    if (err) { return handleError(res, err); }
    if(!dataflow || dataflow.owner != req.user.email) { return res.send(404); }
    console.log("updating");
    dataflow.nodes = [];
    for (var i = 0; i < updatedDataflow.nodes.length; ++i) {
      dataflow.nodes.push(updatedDataflow.nodes[i]);
    }
    dataflow.edges = [];
    for (i = 0; i < updatedDataflow.edges.length; ++i) {
      dataflow.edges.push(updatedDataflow.edges[i]);
    }
    dataflow.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, dataflow);
    });
  });
};

// Deletes a dataflow from the DB.
exports.destroy = function(req, res) {
  Dataflow.findById(req.params.id, function (err, dataflow) {
    if(err) { return handleError(res, err); }
    if(!dataflow) { return res.send(404); }
    dataflow.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

// Get a single thing
exports.run = function(req, res) {
  //var child = exec('ls -lh /usr',
  var child = exec('$HOME/bin/generate.sh '+ req.params.id,
    function (error, stdout, stderr) {
      var str = stdout.toString();
      console.log('stdout: ' + str);
      console.log('stderr: ' + stderr);
      if (error !== null) {
        console.log('exec error: ' + error);
      }
      return res.json({running:req.params.id, 'stdout': str});
    });
};

function handleError(res, err) {
  return res.send(500, err);
}
