import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import axios from 'axios'
import { Navigate } from 'react-router-dom'

class Addcenter extends Component {
    constructor() {
        super()
        this.state = {
            name: '',
            address: '',
            latitude: '',
            longitude: '',
            max_bookings: [],
            activity_bookings: [],
            party_bookings: [],
            errors: {}
        }
    }
    gotosignin() {
        this.props.navigate('/signin')
    }
    onChange = e => {
        this.setState({ [e.target.id]: e.target.value })
    }
    onSubmit = e => {
        e.preventDefault()
        const newUser = {
            name: this.state.name,
            address: this.state.address,
            latitude: this.state.latitude,
            longitude: this.state.longitude,
            max_bookings: this.state.max_bookings,
            activity_bookings: this.state.activity_bookings,
            party_bookings: this.state.party_bookings
        }
        axios
            .post('/api/addcenter', newUser)
            .then(() => { })
            .catch(err => console.log(err.toString()))
        this.setState({
            ["Redirect"]: "/profile"
        })
        // console.log(newUser)
    }
    render() {
        const { errors } = this.state
        if (this.state.Redirect) {
            return <Navigate to={this.state.Redirect} />
        }
        return (
            <div className='container'>
                <div className='row'>
                    <div className='col s8 offset-s2'>
                        <form noValidate onSubmit={this.onSubmit}>
                            <div class="form-group">
                                <label htmlFor='name'>Name</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.name}
                                    error={errors.name}
                                    id='name'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br />
                            <div class="form-group">
                                <label htmlFor='address'>Address</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.address}
                                    error={errors.address}
                                    id='address'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br />
                            <div class="form-group">
                                <label htmlFor='longitude'>Longitude</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.longitude}
                                    error={errors.longitude}
                                    id='longitude'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br />
                            <div class="form-group">
                                <label htmlFor='latitude'>Latitude</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.latitude}
                                    error={errors.latitude}
                                    id='latitude'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br />
                            <div className='col s12' style={{ paddingLeft: '11.250px' }}>
                                <button
                                    type='submit'
                                    class="btn btn-primary"
                                >
                                    Add center
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        )
    }
}
export default Addcenter
