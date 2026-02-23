const mongoose = require('mongoose');
const schema = new mongoose.Schema({}, { timestamps: true, strict: false });
module.exports = mongoose.model('Block', schema);
