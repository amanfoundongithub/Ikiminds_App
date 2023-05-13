import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import Container from '@mui/material/Container';
class Landing extends Component {
  render() {
    return (<>
    <Container maxWidth="sm">
      <Grid container spacing={2}>
        <Grid item xs={6}>
          <Button variant="contained">
            <Link
              to='/signup'
            >
              signup
            </Link></Button> </Grid> <Grid item xs={6}>
          <Button variant="contained">
            <Link
              to='/signin'
            >
              signIn
            </Link>
          </Button>
        </Grid></Grid></Container>
    </>
    )
  }
}
export default Landing
