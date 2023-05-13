const mongoose = require("mongoose");
const {ObjectId} = mongoose.Schema.Types;

const ActivityBookingSchema = new mongoose.Schema({

  // start time of the party
  dropOffTime: {
      type: String,
      required: [true, "Please enter the drop_off_time of the activity"],
  },

  // duration of the party
  duration: {
    type: Number,
    required: [true, "Please enter duration of Party"],
  },
  
  // ID of the parent who booked
  parentEmail: {
    type: String,
    required: true,
    ref: "Parent",
  },

  // store the time of booking
  bookingTime: {
    type: Date,
    required: [true, "Please enter the time of activity booking"],
  },

  // ID of the child enrolled in activities.
  childName: [{
    type: String,
    ref: "Child",
  }],

  // ID of the booked activities
  activityName: [{
    type: String,
    ref: "Activity",
  }],

  centerName: {
    type: String,
    required: true
  }
});

const PartyBooking = mongoose.model("ActivityBooking", ActivityBookingSchema);
module.exports = PartyBooking;