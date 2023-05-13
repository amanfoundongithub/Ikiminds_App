const User = require('../models/Employee')

exports.profile = (req, res, next) => {
  // console.log(req)
  let { id } = req.body
  console.log('id:' + id)
  User.findOne({ _id: id })
    .then(user => {
      if (user) {
        return res.status(200).json({
          firstname: user.firstname,
          lastname: user.lastname,
          email: user.email,
          contactnumber: user.contactnumber,
          rank: user.rank
        })
      }
    })
    .catch(err => {
      console.log(err)
      res.status(500).json({ erros: err })
    })
}

