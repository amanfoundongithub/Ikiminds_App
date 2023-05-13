import React, { useState } from 'react'
import { Route, Routes } from 'react-router-dom'
import jwt_decode from 'jwt-decode'

import Landing from './components/layout/Landing'
import Signup from './components/auth/signup'
import Signin from './components/auth/signin'
import { Navigate } from 'react-router-dom'
import { Profile } from './components/profile/profile'
import setAuthToken from './utils/setAuthToken'
import Navbar from './components/layout/navbar'
import Changeprices from './components/administration/Changeprices'
import Addcenter from './components/administration/Addcenter'
import AddEmployee from './components/administration/Addemployee'
import Addmanager from './components/administration/Addmanager'
import Changeavailibility from './components/administration/Availibility'
let isauthenticated = false
function checkauthenticated(setcurrentuser, currentuser) {
  if (localStorage.jwtToken) {
    // Set auth token header auth
    const token = localStorage.jwtToken
    setAuthToken(token)
    // Decode token and get user info and exp
    const decoded = jwt_decode(token)
    isauthenticated = true
    if (!currentuser) setcurrentuser(decoded.userId)

  }
}

function PrivateRoute({ children }) {
  const auth = isauthenticated
  return auth ? children : <Navigate to='/signin' />
}

function App() {
  const [currentuser, setCurrentUser] = useState('')
  checkauthenticated(setCurrentUser, currentuser)
  return (
    <div className='App'>
      <Routes>
        <Route path='/' element={
          <Signin
            setuser={user => setCurrentUser(user)}
            authentication={isauthenticated}
          />
        } />
        <Route
          path='/signup'
          authentication={isauthenticated}
          element={<Signup />}
        />
        <Route
          path='/signin'
          element={
            <Signin
              setuser={user => setCurrentUser(user)}
              authentication={isauthenticated}
            />
          }
        />
        <Route
          path='/profile'
          element={
            <PrivateRoute>
              <Profile
                setuser={user => setCurrentUser(user)}
                user={currentuser}
              />
            </PrivateRoute>
          }
        />
        <Route
          path='/Changeprices'
          element={
            <PrivateRoute>
              <Changeprices
                setuser={user => setCurrentUser(user)}
                user={currentuser}
              />
            </PrivateRoute>
          }
        />
        <Route
          path='/addcenter'
          element={
            <PrivateRoute>
              <Addcenter
                setuser={user => setCurrentUser(user)}
                user={currentuser}
              />
            </PrivateRoute>
          }
        />
        <Route
          path='/addemployee'
          element={
            <PrivateRoute>
              <AddEmployee
                setuser={user => setCurrentUser(user)}
                user={currentuser}
              />
            </PrivateRoute>
          }
        />
        <Route
          path='/addmanager'
          element={
            <PrivateRoute>
              <Addmanager
                setuser={user => setCurrentUser(user)}
                user={currentuser}
              />
            </PrivateRoute>
          }
        />
        <Route
          path='/changeavailibility'
          element={
            <PrivateRoute>
              <Changeavailibility
                setuser={user => setCurrentUser(user)}
                user={currentuser}
              />
            </PrivateRoute>
          }
        />
      </Routes>
    </div>
  )
}

export default App
