const mongoose = require('mongoose');
const User = require('./UserB');
const sessionSchema = mongoose.Schema({
    Users : [User.schema],
    RoomID : String
}, {'collection' : 'Sessions'});
const sessionModel = mongoose.model("Session", sessionSchema);
module.exports = sessionModel;
