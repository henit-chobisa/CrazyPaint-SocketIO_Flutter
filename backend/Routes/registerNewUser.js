const express = require('express');
const User = require('../models/UserB');
const router = express.Router();

router.post('/', async (req, res) => {
    const {userName, email, number, photoURL, password} = req.body;
    const user = await User.findOne(email);
    if (user == null){
        user = User({userName, email, number, photoURL});
        user.setPassword(password);
        await user.save();
    }
    else {
        res.send("User already exist with this email");
    }


})

module.exports = router;