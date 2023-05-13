const mongoose = require('mongoose')

const ChildSchema = mongoose.Schema({
    // Name of the child
    name :
    {
        type : String, 
        required : true,
    },

    // Email ID of the parent
    date_of_birth : 
    {
        type : Date,
        required: [true,'Heh'],
    }, 

    // Gender of the child
    gender: 
    {
        type: String, 
        required: true,
    }
})


module.exports = mongoose.model('Child',ChildSchema) 