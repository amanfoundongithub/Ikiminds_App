const mongoose = require('mongoose')

const ParentSchema = mongoose.Schema({
    // Name of the parent
    name : {
        type : String, 
        required : [true,'Name is required'],
    },

    // Email ID of the parent
    email : 
    {
        type : String,
        unique : [true,'Unique'],
        required: [true,'heh'],
    }, 

    password : {
        type : String, 
        required : [true,'Name is required'],
    }, 

    // phone number of the parent 
    mobile_no : {
        type : Number, 
        minLength : [10,'Heh'],
        maxLength : [10,'Heh'],
    },

    // Array of object IDs of the children of the parent
    children : [mongoose.Schema.Types.ObjectId],
})

module.exports = mongoose.model('Parent',ParentSchema);