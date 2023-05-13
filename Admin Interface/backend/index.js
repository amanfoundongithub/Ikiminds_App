const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
const bodyParser = require('body-parser')
require('dotenv').config()

//import routes
const authRoutes = require('./routes/auth')
const { db } = require('./models/Employee')

//app
const app = express()
app.use(express.json())

// db
mongoose
  .connect(process.env.DATABASE, {
    useUnifiedTopology: true
  })
  .then(() => console.log('DB Connected'))

//middlewares
app.use(bodyParser.json())
app.use(cors())

//routes middleware
app.use('/api', authRoutes)

const port = process.env.PORT || 8000
app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on ${port}`)
})
