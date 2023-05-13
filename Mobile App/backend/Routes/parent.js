const express = require('express')
const router = express.Router() 

const Parent  = require('../Models/parent')
const Child  = require('../Models/child')

const bcrypt =  require('bcrypt') 
const nodemailer = require('nodemailer');

router.post('/checkemail',async (request,response)=>{
  const user = await Parent.findOne({email: request.body.email}); // conition here
  try{
    if(user){
      response.status(400).send({exists: true});
    }
    else {
      response.status(200).send({exists: false});
    }
  }
  catch(exception){
    response.status(404).send(exception);
  }
})

router.post('/signup',async (request,response)=>{ // storing a new "user" in the database

  const salt = await bcrypt.genSalt(10);
  const hashPassword = await bcrypt.hash(request.body.password, salt);
  request.body.password = hashPassword;

  const user = new Parent(request.body);
  try {
    await user.save(); 
    response.status(200).send({message: "User created"});
  } catch (error) {
    response.status(400).send(error);
  }

})

router.post("/signin", async (request, response) => { 
    const user = await Parent.findOne({email: request.body.email}); // conition here
    try{
      if (!user) {
        response.status(403).send({ message: "Email does not exist"});	// put 401 here if email does not exist error is to be displayed.
        return;
      }

      const cmp = await bcrypt.compare(request.body.password, user.password);
      if (cmp === false){
        response.status(403).send({ meassage: "Incorrect password"} );
        return;
      }
      response.status(200).send({message: "User authenticated successfully"}); // response in {accessToken: __} object is passed
    }
  
    catch(err){
      response.send(err).status(404);
    }
  });


router.put("/changePassword", async (request, response) => { 
  let {password} = request.body;
  
  const salt = await bcrypt.genSalt(10);
  const hashPassword = await bcrypt.hash(password, salt);
  password = hashPassword;

  await Parent.updateOne({email: request.body.email}, {$set: {password: password}})
  .then(res => {
    response.send({message: "updated"}).status(200);
  })
  .catch(err => {
    response.send(err).status(400);
  })
});

  
router.post("/sendOTP", async (request, response) => { 

  var transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'nikunjproject6@gmail.com',
      pass: 'bvuxycfgcitqpsbp'
    }
  });

  const OTP = Math.floor(100000 + Math.random() * 900000); // [10^5,10^6]
  
  var mailOptions = {
    from: 'nikunjproject6@gmail.com',
    to: request.body.email,
    subject: 'Email verification of the App',
    text: 'OTP to verify your accout is: ' + OTP.toString(),
  };
  
  transporter.sendMail(mailOptions, function(error, info){
    if (error) {
      response.status(400).send({message: "Error sending the email"});
    } else {
      response.status(200).send({OTP: OTP});
    }
  });
});


router.post("/profile", async (request, response) => { // get the profile of the user
  const user = await Parent.findOne({email: request.body.email});
  try {
    response.status(200).send(user); 
  } catch (error) {
    response.status(400).send(error);
  }
});

// return the array of children corresponding to parent

router.post('/children', async (request,response)=>{

  await Parent.findOne({email: request.body.email})
  .then(res => {
    const array = res.children;
    let output = []

    const fun = async ()=> {
      for(let i = 0 ; i < array.length ; i++)
      {
        let id = array[i] 
        const child = await Child.findById(id); 
        output.push(child) 
      }
    }

    fun().then(()=>{
      response.status(200).send(output) 
    }).catch((err)=>{
      response.status(400).send(err) 
    })
  })
})

router.put("/update/profile", async (request, response) => { // get the profile of the user
  const user = await Parent.updateOne({email: request.body.email}, {$set: request.body});
  try {
    response.status(200).send(user); 
  } catch (error) {
    response.status(400).send(error);
  }
});

router.put('/update/addchild', async (request,response) =>{
  const parent = request.body.parent 
  
  const name = request.body.name 
  const DOB = request.body.DOB 
  const gender = request.body.gender 

  const family = await Parent.findOne({email : parent}) 

  const child = new Child({
    name : name,
    date_of_birth : DOB,
    gender : gender,
  })

  child.save().then((res)=>{
  
    family.children.push(res._id);

    family.save().then(()=>{

      response.status(200).send('OK')
      
    }).catch((err)=>{
      response.status(400).send(err)
    })
  }).catch((err)=>{
    
    response.status(401).send(err) 
  })
})

module.exports = router 
