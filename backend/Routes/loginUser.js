const express = require('express');
const User = require('../models/UserB');
const router = express.Router();

router.post('/', async (req, res) => {
    const {email, password} = req.body;
    const user = await User.findOne({email});
    if (user == null){
        res.sendStatus(400);
    }
    else {
        const validation = user.validatePassword(password);
        if (validation){
            res.sendStatus(200);
        }
        else{
            res.sendStatus(400);
        }

    }
})

module.exports = router;
