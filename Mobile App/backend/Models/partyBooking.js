const mongoose = require("mongoose");
const {ObjectId} = mongoose.Schema.Types;

const PartyBookingSchema = new mongoose.Schema({

  // start time of the party
  startTime: {
      type: String,
      required: [true, "Please enter the start time of the party"],
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
  
  // ID of the booked center
  centerAddress: {
    type: String,
    required: true,
  },

  // store the time of booking
  bookingTime: {
    type: Date,
    required: [true, "Please enter the tiem of party booking"],
  },

  // number of adults in the party
  adults: {
    type: Number, 
    required : true,
  },

  // number of children in party
  children: {
    type: Number, 
    required : true,
  }
});

const PartyBooking = mongoose.model("PartyBooking", PartyBookingSchema);
module.exports = PartyBooking;