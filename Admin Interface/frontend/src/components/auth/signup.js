import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import axios from 'axios'
class signup extends Component {
  constructor () {
    super()
    this.state = {
      firstname: '',
      lastname: '',
      email: '',
      contactnumber: '',
      rank: '',
      password: '',
      password2: '',
      errors: {}
    }
  }
  gotosignin () {
    this.props.navigate('/signin')
  }
  onChange = e => {
    this.setState({ [e.target.id]: e.target.value })
  }
  onSubmit = e => {
    e.preventDefault()
    const newUser = {
      firstname: this.state.firstname,
      lastname: this.state.lastname,
      email: this.state.email,
      contactnumber: this.state.contactnumber,
      rank:this.state.rank,
      password: this.state.password,
      password_confirmation: this.state.password2
    }
    axios
      .post('/api/signup', newUser)
      .then(() => {})
      .catch(err => console.log(err.toString()))
    this.gotosignin()
    // console.log(newUser)
  }
  render () {
    const { errors } = this.state
    return (
      <div className='container'>
        <div className='row'>
          <div className='col s8 offset-s2'>
            <Link to='/' className='btn-flat waves-effect'>
              <i className='material-icons left'>keyboard_backspace</i> Back to
              home
            </Link>
            <div className='col s12' style={{ paddingLeft: '11.250px' }}>
              <h4>
                <b>Register</b> below
              </h4>
              <p className='grey-text text-darken-1'>
                Already have an account? <Link to='/signin'>Log in</Link>
              </p>
            </div>
            <form noValidate onSubmit={this.onSubmit}>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.firstname}
                  error={errors.firstname}
                  id='firstname'
                  type='text'
                />
                <label htmlFor='firstname'>FirstName</label>
              </div>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.lastname}
                  error={errors.lastname}
                  id='lastname'
                  type='text'
                />
                <label htmlFor='lastname'>LastName</label>
              </div>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.email}
                  error={errors.email}
                  id='email'
                  type='text'
                />
                <label htmlFor='email'>Email</label>
              </div>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.contactnumber}
                  error={errors.contactnumber}
                  id='contactnumber'
                  type='text'
                />
                <label htmlFor='contactnumber'>contactnumber</label>
              </div>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.rank}
                  error={errors.rank}
                  id='rank'
                  type='text'
                />
                <label htmlFor='rank'>rank</label>
              </div>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.password}
                  error={errors.password}
                  id='password'
                  type='text'
                />
                <label htmlFor='password'>Password</label>
              </div>
              <div className='input-field col s12'>
                <input
                  onChange={this.onChange}
                  value={this.state.password2}
                  error={errors.password2}
                  id='password2'
                  type='text'
                />
                <label htmlFor='password2'>Confirm Password</label>
              </div>
              <div className='col s12' style={{ paddingLeft: '11.250px' }}>
                <button
                  style={{
                    width: '150px',
                    borderRadius: '3px',
                    letterSpacing: '1.5px',
                    marginTop: '1rem'
                  }}
                  type='submit'
                  className='btn btn-large waves-effect waves-light hoverable blue accent-3'
                >
                  Sign up
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    )
  }
}
export default signup
