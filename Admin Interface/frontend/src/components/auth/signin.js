import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import setAuthToken from '../../utils/setAuthToken'
import axios from 'axios'
import jwt_decode from 'jwt-decode'
import { withRouter } from '../navigation/withRouter'
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import { TextField } from "@mui/material";
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';

class signin extends Component {
  constructor() {
    super()
    this.state = {
      email: '',
      password: '',
      errors: {}
    }
  }
  componentDidMount() {
    // If logged in and user navigates to Register page, should redirect them to dashboard

    if (this.props.authentication && localStorage.jwtToken) {
      this.props.navigate('/profile')
    }
  }
  gotoprofile() {
    console.log('gotoprofile')
    this.props.navigate('/profile')
  }
  onChange = e => {
    this.setState({ [e.target.id]: e.target.value })
  }
  onSubmit = e => {
    e.preventDefault()
    const userData = {
      email: this.state.email,
      password: this.state.password
    }
    axios
      .post('/api/signin', userData)
      .then(res => {
        // Save to localStorage// Set token to localStorage
        const { token } = res.data
        localStorage.setItem('jwtToken', token)
        // Set token to Auth header
        setAuthToken(token)
        // Decode token to get user data
        const decoded = jwt_decode(token)
        // console.log(decoded)
        // Set current user
        this.props.setuser(decoded.userId)
        this.gotoprofile()
      })
      .catch(err => console.log(err.toString()))
  }
  render() {
    const { errors } = this.state
    return (<><Grid
      container
      spacing={0}
      direction="column"
      alignItems="center"
      justifyContent="center"
      style={{ minHeight: '100vh' }}
    >
      <Grid item xs={3}>
        <div className='container'>
          <div style={{ marginTop: '4rem' }} className='row'>
            <Stack direction="column" spacing={4}>
              <div className='col s8 offset-s2'>
                <h1>KIDVENTURES</h1>
                <br />
                <form noValidate onSubmit={this.onSubmit}>
                  <div className='input-field col s12'>
                    <TextField
                      label="Email"
                      onChange={this.onChange}
                      value={this.state.email}
                      error={errors.email}
                      id='email'
                    />
                  </div>
                  <br></br>
                  <div className='input-field col s12'>
                    <TextField
                      label="Password"
                      onChange={this.onChange}
                      value={this.state.password}
                      error={errors.password}
                      id='password'
                      type='password'
                    />
                  </div>
                  <br></br>
                  <div className='col s12' style={{ paddingLeft: '33%' }}>
                    <Button variant="contained"
                      type='submit'
                      className='btn btn-large waves-effect waves-light hoverable blue accent-3'
                    >
                      Login
                    </Button>
                  </div>
                </form>
              </div>
            </Stack>
          </div>
        </div></Grid>  </Grid></>
    )
  }
}
export default withRouter(signin)
