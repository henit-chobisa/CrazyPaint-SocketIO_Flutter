const express = require('express');
const Router = express.Router();
const {RtcTokenBuilder, RtcRole} = require('agora-access-token');
const nocache = require('../MiddleWare/noCache');
const url = require('url');

const APP_ID = "08478a3f085f4cbdb8c246d288dfb81b";
const APP_CERTIFICATE = "05eeac727166436d8b282517f9d07b1f"

Router.get('/', nocache, (req, res) => {
    const query = url.parse(req.url, true).query;
    const channelName = query.channel;
    const uid = query.uid;
    let role = RtcRole.SUBSCRIBER;
    if (query.role == 'publisher'){
        role = RtcRole.PUBLISHER;
    }
    let expireTime = 36000;
    const currentTime = Math.floor(Date.now()/1000);
    const previlegeExpiryTime = currentTime + expireTime;
    const token = RtcTokenBuilder.buildTokenWithUid(APP_ID, APP_CERTIFICATE, channelName,uid, role, previlegeExpiryTime);
    console.log(token);
    res.json({'token' : token});

})



module.exports = Router;