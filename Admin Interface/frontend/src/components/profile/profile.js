import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import { Stack, TextField } from '@mui/material'
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import { Button } from '@mui/material';
function setdata(setposts, id, posts) {
  return axios
    .post('/api/profile', { id })
    .then(res => setposts(res.data))
    .catch(err => console.log('dasdas' + err.toString()))
}

function Changeavailibility() {
  const navigate = useNavigate()
  return (
    <Button variant="contained"
      onClick={() => {
        navigate('/changeavailibility')
      }}
    >Update Slots</Button>
  )
}
function Changeprices() {
  const navigate = useNavigate()
  return (
    <Button variant="contained"
      onClick={() => {
        navigate('/Changeprices')
      }}
    >Change Prices</Button>
  )
}

function AddCenter() {
  const navigate = useNavigate()

  return (
    <Button variant="contained"
      onClick={() => {
        navigate('/addcenter')
      }}>Add Center</Button>
  )
}

function AddEmployee() {
  const navigate = useNavigate()

  return (
    <Button variant="contained"
      onClick={() => {
        navigate('/addemployee')
      }}>Add Employee</Button>
  )
}

function AddManager() {
  const navigate = useNavigate()
  return (
    <Button variant="contained"
      onClick={() => {
        navigate('/addmanager')
      }}
    >Add Manager</Button>
  )
}

export function Profile(props) {
  const navigate = useNavigate()
  let id = props.user
  let firstname,
    lastname,
    email,
    contactnumber,
    rank
  const [posts, setposts] = useState([])
  useEffect(() => {
    setdata(setposts, id)
  }, [])
  firstname = posts.firstname
  lastname = posts.lastname
  email = posts.email
  contactnumber = posts.contactnumber
  rank = posts.rank

  let options = []
  if (rank == "Manager" || rank == "Admin")
    options.push(<Grid item xs={4}><Changeprices /></Grid>,
      <Grid item xs={4}><AddEmployee /></Grid>)
  if (rank == "Admin")
    options.push(<Grid item xs={4}> <AddManager /></Grid>,
      <Grid item xs={4}> <AddCenter /></Grid>)
  return (
    <>
      <span class="align-middle">
        <Container maxWidth="sm">
          <div class="center">
            <Grid container alignItems='center' spacing={1}>
              <Grid item xs={6}><h2>Name : {firstname} {lastname}</h2></Grid>
              <Grid item xs={6}><h2>Mail : {email}</h2></Grid>
              <Grid item xs={6}><h2>Contact : {contactnumber}</h2></Grid>
              <Grid item xs={6}><h2>Role : {rank}</h2></Grid>
            </Grid>
            <br />
            <Grid container spacing={1}>
              {options}
              <Grid item xs={4}>
                <Button variant="contained"
                  onClick={() => {
                    localStorage.removeItem('jwtToken')
                    navigate('/signin')
                    props.setuser('')
                  }}
                >
                  logout
                </Button>
              </Grid>
            </Grid></div>
        </Container >
      </span>
    </>
  )
}
