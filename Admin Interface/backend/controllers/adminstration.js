const Centers = require('../models/Centers');
const Activity = require('../models/Activity');
const Availibility = require('../models/Availibility');
exports.getprices = (req, res, next) => {
  // console.log(req)
  Activity.find()
    .then(user => {
      if (user) {
        console.log("asdasda", user)
        return res.status(200).json({
          useris: user
        })
      }
    })
    .catch(err => {
      console.log(err)
      console.log("asdasda", user)
      res.status(500).json({ erros: err })
    })
}

exports.updateprices = (req, res, next) => {
  console.log(req)
  let { Origami, Painting, Storytelling, Dancing, ClayModelling } = req.body
  Activity.findOneAndUpdate({ name: "Painting" }, { price: Painting })
    .then(user => {
      if (user) {
        console.log("asdasda", user)
      }
    })
    .catch(err => {
      console.log(err)
      console.log("asdasda", user)
      res.status(500).json({ erros: err })
    })

  Activity.findOneAndUpdate({ name: "Origami" }, { price: Origami })
    .then(user => {
      if (user) {
        console.log("asdasda", user)

      }
    })
    .catch(err => {
      console.log(err)
      console.log("asdasda", user)
      res.status(500).json({ erros: err })
    })

  Activity.findOneAndUpdate({ name: "Story telling" }, { price: Storytelling })
    .then(user => {
      if (user) {
        console.log("asdasda", user)

      }
    })
    .catch(err => {
      console.log(err)
      console.log("asdasda", user)
      res.status(500).json({ erros: err })
    })

  Activity.findOneAndUpdate({ name: "Dancing" }, { price: Dancing })
    .then(user => {
      if (user) {
        console.log("asdasda", user)
      }
    })
    .catch(err => {
      console.log(err)
      console.log("asdasda", user)
      res.status(500).json({ erros: err })
    })

  Activity.findOneAndUpdate({ name: "Clay Modelling" }, { price: ClayModelling })
    .then(user => {
      if (user) {
        console.log("asdasda", user)
        return res.status(200).json({
        })
      }
    })
    .catch(err => {
      console.log(err)
      console.log("asdasda", user)
      res.status(500).json({ erros: err })
    })
}


exports.addcenter = (req, res, next) => {
  let {
    name,
    address,
    latitude,
    longitude,
    max_bookings,
    activity_bookings,
    party_bookings,
  } = req.body
  Center.insertOne({
    name: name,
    address: address,
    latitude: latitude,
    longitude: longitude,
    max_bookings: max_bookings,
    activity_bookings: activity_bookings,
    party_bookings: party_bookings
  }).then(() => { }).error(err => { console.log(err) });
}

exports.getcenters = async (req, res, next) => {
  var list = await Centers.find({})
  console.log(list)
  res.status(200).send(list)
}

exports.changeavailibility = (req, res, next) => {
  let { Date_time, Duration, Address, Activity } = req.body;
  console.log(req.body)
  Availibility.insertMany({
    Date_time: Date_time,
    Duration: Duration,
    Address: Address,
    Activity: Activity
  })
    .then(() => res.status(200).send())
    .catch(err => { console.log(err) });
}