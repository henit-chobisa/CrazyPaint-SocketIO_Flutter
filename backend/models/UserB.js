const mongoose = require('mongoose');
const crypto = require('crypto');

const UserModel = mongoose.Schema({
    userName : String,
    email : String,
    number : String,
    photoURL : String,
    hash : String,
    salt : String,
}, { "collection" : "Users"});

UserModel.methods.setPassword = function(password){
    try {
        this.salt = crypto.randomBytes(32).toString('hex');
        this.hash = crypto.pbkdf2Sync(password, this.salt, 10000, 256, 'sha256').toString('hex');
        return 1;
    }
    catch(err){
        console.log(err);
    }
}

UserModel.methods.validatePassword = function (password) {
    try {
        const hash = crypto.pbkdf2Sync(password, this.salt, 10000, 256, 'sha256').toString('hex');
        return this.hash == hash;
    }
    catch (err) {
        console.log(err);
    }
};

const User = mongoose.model("User", UserModel);
module.exports = User;