'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var DataflowSchema = new Schema({
  name: String,
  info: String,
  active: Boolean
});

module.exports = mongoose.model('Dataflow', DataflowSchema);