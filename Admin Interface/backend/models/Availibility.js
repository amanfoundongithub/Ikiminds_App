const mongoose = require('mongoose')
const Schema = mongoose.Schema

let availibilitySchema = new Schema(
    {
        Activity: {
            type: String,
            required: true
        },
        Address: {
            type: String,
            required: true
        },
        Duration: {
            type: Number,
            required: true
        },
        Date_time: {
            type: Date,
            required: true
        }

    }
)
module.exports = mongoose.model('Availibility',availibilitySchema)
