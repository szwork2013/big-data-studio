'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var NodeParameterSchema = new Schema({
    name: String,
    value: String
  },
  { _id: false}
);

var NodeSchema = new Schema({
    name: String,
    definition: String,
    x: Number,
    y: Number,
    parameters:[NodeParameterSchema]
  },
  { _id: false}
);

var EdgeSchema = new Schema({
    from_node: String,
    from_connector: String,
    to_node: String,
    to_connector: String
  },
  { _id: false}
);
var DataflowSchema = new Schema({
  name: String,
  owner: String,
  description: String,
  nodes: [NodeSchema],
  edges: [EdgeSchema]
});

/**
 * Validations
 */
DataflowSchema.path('name').validate(function (str) {
  return str.length>0;
}, 'Name must not be empty');

module.exports = mongoose.model('Dataflow', DataflowSchema);
