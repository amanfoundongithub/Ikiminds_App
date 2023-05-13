import React, { useEffect, useState, Component } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import { Navigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

class Changeprices extends Component {
    constructor() {
        super()
        this.state = {
            Origami: '',
            Painting: '',
            Storytelling: '',
            Dancing: '',
            ClayModelling: '',
            errors: {},
            Redirect: null
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
            .post('/api/getprices')
            .then((response) => {
                this.setState({
                    ["Origami"]: response.data.useris[0].price,
                    ["Painting"]: response.data.useris[1].price,
                    ["Storytelling"]: response.data.useris[2].price,
                    ["Dancing"]: response.data.useris[3].price,
                    ["ClayModelling"]: response.data.useris[4].price
                })
                    .error((err) => { console.log(err) })
            })
    }
    onSubmit = e => {
        e.preventDefault()
        const newUser = {
            Origami: this.state.Origami,
            Painting: this.state.Painting,
            Storytelling: this.state.Storytelling,
            Dancing: this.state.Dancing,
            ClayModelling: this.state.ClayModelling,
        }
        axios
            .post('/api/updateprices', newUser)
            .then(() => { })
            .catch(err => console.log(err.toString()))
        this.setState({
            ["Redirect"]: "/profile"
        })
        // console.log(newUser)
    }
    render() {
        if (this.state.Redirect) {
            return <Navigate to={this.state.Redirect} />
        }
        const { errors } = this.state
        return (
            <>

                <form noValidate onSubmit={this.onSubmit}>
                    <div className='form-group'>
                        <label For='Origami'>Origami</label>
                        <div class="form-outline mb-4">
                            <input
                                onChange={this.onChange}
                                value={this.state.Origami}
                                error={errors.Origami}
                                id='Origami'
                                type='text'
                                class="form-control"
                            /></div>
                    </div>
                    <div className='form-group'>
                        <div className='input-field col s12'>
                            <label htmlFor='Painting'>Painting</label>
                            <div class="form-outline mb-4">
                                <input
                                    onChange={this.onChange}
                                    value={this.state.Painting}
                                    error={errors.Painting}
                                    id='Painting'
                                    type='text'
                                    class="form-control"
                                />
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label htmlFor='Storytelling'>Storytelling</label>
                        <div class="form-outline mb-4">
                            <input
                                onChange={this.onChange}
                                value={this.state.Storytelling}
                                error={errors.Storytelling}
                                id='Storytelling'
                                type='text'
                                class="form-control"
                            />
                        </div>
                    </div>
                    <div className='form-group'>
                        <label htmlFor='Dancing'>Dancing</label>
                        <div class="form-outline mb-4">
                            <input
                                onChange={this.onChange}
                                value={this.state.Dancing}
                                error={errors.Dancing}
                                id='Dancing'
                                type='text'
                                class="form-control"
                            />
                        </div>
                    </div>
                    <div className='form-group'>
                        <label htmlFor='ClayModelling'>ClayModelling</label>
                        <div class="form-outline mb-4">
                            <input
                                onChange={this.onChange}
                                value={this.state.ClayModelling}
                                error={errors.ClayModelling}
                                id='ClayModelling'
                                type='text'
                                class="form-control"
                            />
                        </div>
                    </div>
                    <div className='col s12' style={{ paddingLeft: '11.250px' }}>
                        <button
                            type='submit'
                            class="btn btn-primary"
                        >
                            Update
                        </button>
                    </div>
                </form>
            </>
        )
    }
}

export default Changeprices