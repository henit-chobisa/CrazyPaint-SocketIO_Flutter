const express = require("express");
const url = require('url');
const sessionModel = require("../models/Sessions");
const router = express.Router();

router.get('/', async (req, res) => {
   const query = url.parse(req.url,true).query;
   const RoomID = query.RoomID;
   const session = await sessionModel.findOne({RoomID});
   if (session != null){
       res.send(session.Users);
   }
   else{
       res.send("No room like this");
   }
});

module.exports  = router;