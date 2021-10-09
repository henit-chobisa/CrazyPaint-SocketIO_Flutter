const express = require("express");

module.exports = function(io){
    const router = express.Router();

    io.on('connection', async function (socket){
        var currentRoom = socket.handshake.query.roomID;
        console.log(currentRoom);
        await socket.join(currentRoom);
        var users = [];

        socket.on('newUser', function(data){
            users.push(data);
            socket.in(currentRoom).broadcast.emit('getCurrentUsers', users);
            socket.in(currentRoom).broadcast.emit('newUser', data);
            console.log(users);
            
        });
        socket.on('getCurrentUsers', function(data){
            socket.in(currentRoom).broadcast.emit('getCurrentUsers', users);
        })
        socket.on('userLeft', function(data){
            socket.in(currentRoom).broadcast.emit('userLeft', data);
        })

        socket.on('coordinates', async function(message){
            socket.in(currentRoom).broadcast.emit('coordinates', message);
        })
        socket.on('completed', async function (completed){
            socket.in(currentRoom).broadcast.emit('completed', completed);
        })
    })
    return router;
}