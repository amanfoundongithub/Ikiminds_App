import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import axios from 'axios'
import { Navigate } from 'react-router-dom'
class AddEmployee extends Component {
    constructor() {
        super()
        this.state = {
            firstname: '',
            lastname: '',
            email: '',
            contactnumber: '',
            rank: 'Manager',
            address: '',
            password: '',
            password2: '',
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
    onSubmit = e => {
        e.preventDefault()
        const newUser = {
            firstname: this.state.firstname,
            lastname: this.state.lastname,
            email: this.state.email,
            contactnumber: this.state.contactnumber,
            rank: this.state.rank,
            password: this.state.password,
            password_confirmation: this.state.password2,
            address: this.state.address
        }
        axios
            .post('/api/signup', newUser)
            .then(() => { })
            .catch(err => console.log(err.toString()))
        this.setState({
            ["Redirect"]: "/profile"
        })

        // console.log(newUser)
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
            <div className='container'>
                <div className='row'>
                    <div className='col s8 offset-s2'>
                        <form noValidate onSubmit={this.onSubmit}>
                            <div class="form-group">
                                <label htmlFor='firstname'>FirstName</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.firstname}
                                    error={errors.firstname}
                                    id='firstname'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br/>
                            <div class="form-group">
                                <label htmlFor='lastname'>LastName</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.lastname}
                                    error={errors.lastname}
                                    id='lastname'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br/>
                            <div class="form-group">
                                <label htmlFor='email'>Email</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.email}
                                    error={errors.email}
                                    id='email'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br/>
                            <div class="form-group">
                                <label htmlFor='contactnumber'>Contact</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.contactnumber}
                                    error={errors.contactnumber}
                                    id='contactnumber'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br/>
                            <div class="form-group">
                                <label htmlFor='password'>Password</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.password}
                                    error={errors.password}
                                    id='password'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br/>
                            <div class="form-group">
                                <label htmlFor='password2'>Confirm Password</label>
                                <input
                                    onChange={this.onChange}
                                    value={this.state.password2}
                                    error={errors.password2}
                                    id='password2'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                            <br/>
                            <label htmlFor='address'>Center</label>
                            <div class="form-group">
                                <select
                                    class="form-control"
                                    onChange={this.onChange}
                                    value={this.state.address}
                                    id="address"
                                    name="address">
                                    {dropdown}
                                </select>
                            </div>
                            <br/>
                            <div class="form-group">
                                <button
                                    class="btn btn-primary"
                                    type='submit'
                                >
                                    Add Employee
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        )
    }
}
export default AddEmployee
