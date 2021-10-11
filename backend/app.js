const express = require('express');
const app = express();
const cors = require('cors');
var http = require('http');
var server = http.createServer(app);
var io = require('socket.io')(server);
const port = process.env.PORT || 2000;
app.use(cors());
const db = require('./config/Database');
db();

app.use(express.json());
app.use('/login', require('./Routes/registerNewUser'));
app.use('/getToken', require('./Routes/agoraToken'))
app.use(require('./Websockets')(io));

server.listen(port,"0.0.0.0",() => { console.log(`Deployed on port ${port}`)});