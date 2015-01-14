'use strict';

var _ = require('lodash');
var Dataflow = require('./dataflow.model');

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
  Dataflow.findById(req.params.id, function (err, dataflow) {
    if (err) { return handleError(res, err); }
    if(!dataflow) { return res.send(404); }
    var updated = _.merge(dataflow, req.body);
    updated.save(function (err) {
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

function handleError(res, err) {
  return res.send(500, err);
}
