const express = require('express')
const router = express.Router() 

const Activity  = require('../Models/activity')
const Booking = require('../Models/activityBooking')
const Party = require('../Models/partyBooking')
const Center = require('../Models/center')

router.post('/getPrice', async (req, res) => {
    let {activity_name} = req.body;
    // console.log(activity_name)
    const activity_price = await Activity.findOne({name:activity_name})
    try {
        console.log(activity_price)
        res.status(200).json(activity_price); 
    } catch (error) {
        console.log(activity_price)
        res.status(400).json(error);
    }
})

router.post('/confirmBooking', async (req, res) => {
    let {dropOffTime, duration, parentEmail, centerId, childrenString, activityString, center_address, bookingDate} = req.body;
    // console.log(activity_name)
    dropOffTime = bookingDate + " " + dropOffTime;
    childrenString = childrenString[0];
    activityString = activityString[0];
    const activityInstance = new Booking({
        dropOffTime:dropOffTime,
        duration:duration,
        parentEmail:parentEmail,
        bookingTime: Date.now(),
        childName:childrenString,
        activityName:activityString,
        centerName: center_address,
    })
    try {
        let newInstance = await activityInstance.save();
        let center = await Center.findOneAndUpdate({address : center_address}, {$push:{activity_booking:newInstance._id}})
        console.log(center);
        res.status(200).send({message: "Booking confirmed"});
        console.log(activityInstance);
    }
    catch (error) {
        res.status(400).send(error);
        console.log(error);
    }
})

router.post('/confirmParty', async (req, res) => {
    let {startTime, duration, parentEmail, centerAddress,children, adult, bookingDate} = req.body;
    startTime = bookingDate + " " + startTime;
    const partyInstance = new Party({
        startTime:startTime,
        duration:duration,
        parentEmail:parentEmail,
        centerAddress: centerAddress,
        bookingTime: Date.now(),
        adults:adult,
        children:children,
    })
    console.log(partyInstance);
    try {
        let newInstance = await partyInstance.save();
        let center = await Center.findOneAndUpdate({address : centerAddress}, {$push:{party_booking:newInstance._id}})
        console.log(center);
        res.status(200).send({message: "Booking confirmed"});
        // console.log(activityInstance);
    }
    catch (error) {
        res.status(400).send(error);
        console.log(error);
    }
})

router.post('/fetch/activities', async (req, res) => {
    const email = req.body.email;
 
    Booking.find({parentEmail: email})
    .then(response => {
     response.sort((a,b)=>{
         var date1 = new Date(Date.parse(a.dropOffTime))
         var time1 = date1.getTime();
 
         var date2 = new Date(Date.parse(b.dropOffTime))
         var time2 = date2.getTime();
 
         return time2 - time1; 
     })
 
     let output = []
     for(let i = 0 ; i < response.length ; i++){
 
         var elem = response[i].toJSON();
 
         var date1 = new Date(Date.parse(elem.dropOffTime))
         var time1 = date1.getTime();
         var curr = new Date();
         var x = (time1 >= curr.getTime());
 
         elem["upcoming"] = x;
 
         output.push(elem)
     }
     console.log(output);
     res.status(200).send(output);
    })
    .catch(err => {
     res.status(400).send(err);
     })
 })
 
 
 router.post('/fetch/parties', async (req, res) => {
     const email = req.body.email;
  
     Party.find({parentEmail: email})
     .then(response => {
      response.sort((a,b)=>{
          var date1 = new Date(Date.parse(a.startTime))
          var time1 = date1.getTime();
  
          var date2 = new Date(Date.parse(b.startTime))
          var time2 = date2.getTime();
  
          return time2 - time1; 
      })
 
      let output = []
     for(let i = 0 ; i < response.length ; i++){
 
         var elem = response[i].toJSON();
 
         var date1 = new Date(Date.parse(elem.startTime))
         var time1 = date1.getTime();
         var curr = new Date();
         var x = (time1 >= curr.getTime());
 
         elem["upcoming"] = x;
 
         output.push(elem)
     }
     console.log(output);
     res.status(200).send(output);
    })
     .catch(err => {
      res.status(400).send(err);
      })
  })
  
module.exports = router