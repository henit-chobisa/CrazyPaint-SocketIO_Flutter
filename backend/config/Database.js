const mongoose = require("mongoose")

const connect = async () => {
    try {
        await mongoose.connect('mongodb+srv://HenitChobisa:111.Dinesh@cluster0.hyaxg.mongodb.net/myFirstDatabase?retryWrites=true&w=majority', err => {
            if (err) throw err;
            console.log("Database activated")
        })
    }
    catch(err){
        console.log(err);
    }
}

module.exports = connect;