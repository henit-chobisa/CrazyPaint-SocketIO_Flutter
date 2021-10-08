const express = require('express');
const app = express();
var http = require('http');
var server = http.createServer(app);
var io = require('socket.io')(server);
const port = process.env.PORT || 1000;
app.use(express.json());



server.listen(port,"0.0.0.0",() => { console.log(`Deployed on port ${port}`)});