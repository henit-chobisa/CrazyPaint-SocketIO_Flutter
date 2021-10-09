const mongoose = require('mongoose');
const crypto = require('crypto');

const UserModel = mongoose.Schema({
    userName : String,
    email : String,
    photoURL : String,
}, { "collection" : "Users"});

const User = mongoose.model("User", UserModel);
module.exports = User;