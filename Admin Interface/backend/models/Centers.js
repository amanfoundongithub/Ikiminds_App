const mongoose = require("mongoose");
const {ObjectId} = mongoose.Schema.Types;

const CenterSchema = new mongoose.Schema(
  {
  // address of the center
  address: {
    type: String,
    required: true,
  },

  // latitude of center
  latitude: {
    type: Number,
    required: true,
  },

  // longitude of center
  longitude: {
    type: Number,
    required: true,
  },

  // array of max bookings of each activity
  max_bookings: [{
    type: Number,
  }],

  // array of ObjectId of future bookings of the activity
  activity_bookings: [{
    type: ObjectId,
    ref: "ActivityBooking",
  }],

  // array of ObjectId of future party bookings
  party_bookings: [{
    type: ObjectId,
    ref: "PartyBooking",
  }],
});

module.exports = mongoose.model("centers", CenterSchema, 'centers')
