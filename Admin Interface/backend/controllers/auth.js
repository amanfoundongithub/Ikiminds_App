const User = require('../models/Employee')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcrypt')
const { createJWT } = require('../utils/auth')
const Employee = require('../models/Employee')
const emailRegexp =
  /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
exports.signup = (req, res, next) => {
  let {
    firstname,
    lastname,
    email,
    contactnumber,
    rank,
    password,
    password_confirmation,
    address,
  } = req.body
  console.log(req.body)
  let errors = []
  if (!firstname) {
    errors.push({ firstname: 'required' })
  }
  if (!lastname) {
    errors.push({ lastname: 'required' })
  }
  if (!email) {
    errors.push({ email: 'required' })
  }
  if (!contactnumber) {
    errors.push({ contactnumber: 'required' })
  }
  if (!emailRegexp.test(email)) {
    errors.push({ email: 'invalid' })
  }
  if (!rank) {
    errors.push({ rank: 'required' })
  }
  if (!password) {
    errors.push({ password: 'required' })
  }
  if (!password_confirmation) {
    errors.push({
      password_confirmation: 'required'
    })
  }
  if (password != password_confirmation) {
    errors.push({ password: 'mismatch' })
  }
  if (errors.length > 0) {
    console.log(errors)
    return res.status(422).json({ errors: errors })
  }
  Employee.findOne({ email: email })
    .then(user => {
      if (user) {
        return res
          .status(422)
          .json({ errors: [{ user: 'email already exists' }] })
      } else {
        const user = new User({
          firstname: firstname,
          lastname: lastname,
          email: email,
          contactnumber: contactnumber,
          password: password,
          rank: rank,
          address: address
        })
        bcrypt.genSalt(10, function (err, salt) {
          bcrypt.hash(password, salt, function (err, hash) {
            if (err) throw err
            user.password = hash
            user
              .save()
              .then(response => {
                res.status(200).json({
                  success: true,
                  result: response
                })
              })
              .catch(err => {
                res.status(500).json({
                  errors: [{ error: err }]
                })
              })
          })
        })
      }
    })
    .catch(err => {
      res.status(500).json({
        errors: [{ error: 'Something went wrong' }]
      })
    })
}

exports.signin = (req, res) => {
  let { email, password } = req.body
  console.log('signin', email, password)
  let errors = []
  if (!email) {
    errors.push({ email: 'required' })
  }
  if (!emailRegexp.test(email)) {
    errors.push({ email: 'invalid email' })
  }
  if (!password) {
    errors.push({ passowrd: 'required' })
  }
  if (errors.length > 0) {
    return res.status(422).json({ errors: errors })
  }
  Employee.findOne({ email: email })
    .then(user => {
      if (!user) {
        return res.status(404).json({
          errors: [{ user: 'not found' }]
        })
      } else {
        bcrypt
          .compare(password, user.password)
          .then(isMatch => {
            if (!isMatch) {
              return res
                .status(400)
                .json({ errors: [{ password: 'incorrect' }] })
            }
            let access_token = createJWT(user.email, user._id, 3600)

            jwt.verify(
              access_token,
              process.env.TOKEN_SECRET,
              (err, decoded) => {
                if (err) {
                  res.status(500).json({ erros: err })
                }
                if (decoded) {
                  return res.status(200).json({
                    success: true,
                    token: access_token,
                    message: user
                  })
                }
              }
            )
          })
          .catch(err => {
            res.status(500).json({ erros: err.toString() })
          })
      }
    })
    .catch(err => {
      res.status(500).json({ erros: err })
    })
}
