const mongoose = require('mongoose')
const Schema = mongoose.Schema

let activitySchema = new Schema(
  {
    name: {
      type: String,
      required: true
    },
    price:{
        type: Number,
        required: true
    }
  }
)
module.exports = mongoose.model('Activity', activitySchema,"Activity")
