const mongoose = require('mongoose')
const Schema = mongoose.Schema

let employeeSchema = new Schema(
  {
    firstname: {
      type: String,
      required: true
    },
    lastname: {
      type: String,
      required: true
    },
    email: {
      type: String,
      required: true
    },
    contactnumber: {
      type: String,
      required: true
    },
    password: {
      type: String,
      required: true
    },
    rank: {
        type: String,
        required: true
    },
    address:{
      type: String,
    },
  }
)
module.exports = mongoose.model('Employee', employeeSchema,"Employees")
