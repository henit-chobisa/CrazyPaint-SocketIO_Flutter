const express = require("express");

module.exports = function(io){
    const router = express.Router();
    io.on('connection', async function (socket){
        console.log("Connected");
        socket.on('coordinates', async function(message){
            socket.broadcast.emit('coordinates', message);
        })
        socket.on('completed', async function (completed){
            socket.broadcast.emit('completed', completed);
        })
    })
    return router;
}