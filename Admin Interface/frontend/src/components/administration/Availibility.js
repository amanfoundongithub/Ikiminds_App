import React, { useEffect, useState, Component } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import { Navigate } from 'react-router-dom'
class Changeavailibility extends Component {
    constructor() {
        super()
        this.state = {
            Date_time: '',
            Duration: '',
            Address: '',
            Activity: '',
            centers: [],
            errors: {}
        }
    }
    gotosignin() {
        this.props.navigate('/signin')
    }
    onChange = e => {
        this.setState({ [e.target.id]: e.target.value })
    }
    componentDidMount() {
        axios
            .post('/api/getcenters')
            .then((response) => {
                console.log(response.data)
                this.setState({
                    ["centers"]: response.data
                })
                    .error((err) => { console.log(err) })
            })
    }
    onSubmit = e => {
        e.preventDefault()
        const newUser = {
            Date_time: this.state.Date_time,
            Duration: this.state.Duration,
            Address: this.state.Address,
            Activity: this.state.Activity
        }
        axios
            .post('/api/changeavailibility', newUser)
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
        let dropdown = []
        console.log("centers are:", this.state.centers)
        for (let i = 0; i < this.state.centers.length; i++) {
            dropdown.push(<option value={this.state.centers[i].address}>{this.state.centers[i].address}</option>)
        }

        return (
            <div className='container' >
                <div className='row'>
                    <div className='col s8 offset-s2'>
                        <form noValidate onSubmit={this.onSubmit}>
                            <div className='col s12' style={{ paddingLeft: '11.250px' }}>
                                <select
                                    onChange={this.onChange}
                                    value={this.state.Address}
                                    id="Address"
                                    name="Address">
                                    {dropdown}
                                </select>
                                <label htmlFor='Address'>Center</label>
                            </div>
                            <div className='input-field col s12'>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.Date_time}
                                    error={errors.Date_time}
                                    id='Date_time'
                                    type="datetime-local"
                                />
                                <label htmlFor='Date_time'>Date-time</label>
                            </div>
                            <div className='input-field col s12'>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.Duration}
                                    error={errors.Duration}
                                    id='Duration'
                                    type='number'
                                />
                                <label htmlFor='Duration'>Duration</label>
                            </div>
                            <div className='col s12' style={{ paddingLeft: '11.250px' }}>
                                <select
                                    onChange={this.onChange}
                                    value={this.state.Activity}
                                    id="Activity"
                                    name="Activity">
                                    <option value="Origami">Origami</option>
                                    <option value="Painting">Painting</option>
                                    <option value="Story telling">Story Telling</option>
                                    <option value="Dancing">Dancing</option>
                                    <option value="Clay Modelling">Clay Modelling</option>
                                </select>
                                <label htmlFor='Activity'>Activity</label>
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
                                    Update
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        )
    }
}

export default Changeavailibility