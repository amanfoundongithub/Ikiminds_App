const mongoose = require("mongoose");
const {ObjectId} = mongoose.Schema.Types;

const ActivitySchema = new mongoose.Schema({

  // Name of the activity
  name: {
      type: String,
      required: true,
  },

  // Price of the activity
  price: {
    type: Number,
    required: true,
  },  
});

const Activity = mongoose.model('Activity', ActivitySchema, "Activity");
module.exports = Activity;