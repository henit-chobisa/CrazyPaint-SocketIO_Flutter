
const express = require("express");
const {
    userJoin,
    getCurrentUser,
    userLeave,
    getRoomUsers
  } = require('./actions');
  
module.exports = function(io){
    const router = express.Router();

    io.on('connection', async function (socket){

        socket.on('joinRoom', (data) => {
            console.log(data);
            const username = data['username'];
            const email = data['email'];
            const photoURL = data['photoURL'];
            const room = data['room'];
            const user = userJoin(socket.id, username, email, photoURL, room);
            console.log(user);
            socket.join(user.room);
        
            // Send users and room info
            io.to(user.room).emit('roomUsers', {
              room: user.room,
              users: getRoomUsers(user.room)
            });

            socket.on('coordinates', async function(message){
                socket.in(user.room).broadcast.emit('coordinates', message);
            })
            socket.on('completed', async function (completed){
                socket.in(user.room).broadcast.emit('completed', completed);
            })
          });
        
        

       

        
    })
    return router;
}