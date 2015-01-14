'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var SectionSchema   = new Schema({
  name: String,
  index: Number,
  items: [String]
});

SectionSchema.path('name').validate(function (str) {
  return str.length>0;
}, 'Name must not be empty');

module.exports = mongoose.model('Section', SectionSchema);
