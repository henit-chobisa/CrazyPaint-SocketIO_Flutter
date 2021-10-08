const express = require("express");

module.exports = function(io){
    const router = express.Router();
    io.on('connection', async function (socket){
        console.log("Connected");
    })
    return router;
}