'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var ConnectorSchema = new Schema({
  name: String,
  type: String,
  isInput: Boolean
});

var ParameterSchema = new Schema({
  name: String,
  type: String,
  default: String,
  fieldOptions: Schema.Types.Mixed
});

var DefinitionSchema = new Schema({
  name: String,
  group: String,
  width: Number,
  height: Number,
  fill: String,
  parameters: [ParameterSchema],
  connectors: [ConnectorSchema]
});

DefinitionSchema.path('name').validate(function (str) {
  return str.length>0;
}, 'Name must not be empty');

module.exports = mongoose.model('Definition', DefinitionSchema);
