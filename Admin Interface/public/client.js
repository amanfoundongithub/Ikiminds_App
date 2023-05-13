import * as THREE from './build/three.module.js'
import { OrbitControls } from './jsm/controls/OrbitControls.js'
import Stats from './jsm/libs/stats.module.js'
import { GUI } from './jsm/libs/lil-gui.module.min.js'
import { GLTFLoader } from './jsm/loaders/GLTFLoader.js'
import { Scene } from 'three'
//handles for input keys
let keys = {
  w: false,
  s: false,
  a: false,
  d: false,
  r: 1,
  space: false
}
let gameover = false
function getRndInteger (min, max) {
  return Math.floor(Math.random() * (max - min)) + min
}
function removeEntity (object) {
  var selectedObject = scene.getObjectByName(object.name)
  scene.remove(selectedObject)
}
let distance = 1
let consumed = 1
let time = 0
let score = 0
let fueldistance = 0
let fuelflag = false
let fuels = []
let turnangle = 0
let speed = 0
let redtoggle = -1
//stats for car
let fuel = 100
let health = 100
let bluescore = 0,
  greenscore = 0,
  redscore = 0
// const stats = new Stats()
// stats.showPanel(0) // 0: fps, 1: ms, 2: mb, 3+: custom
// document.body.appendChild(stats.dom)

//makes the scene
const scene = new THREE.Scene()
scene.background = new THREE.Color(0xadd8e6)

//Camera
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
)
let cameraTop = new THREE.PerspectiveCamera(
  90,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
)
scene.add(camera)
camera.position.set(0, 10, -100)
camera.rotateY(-Math.PI / 2)
cameraTop.position.set(0, 200, 0)
cameraTop.lookAt(0, 0, 0)
camera.add(cameraTop)

document.getElementById('game').style.display = 'none'
document.getElementById('main').style.display = 'block'
document.getElementById('fuelend').style.display = 'none'
document.getElementById('healthend').style.display = 'none'

//renderer
const renderer = new THREE.WebGLRenderer()
renderer.setSize(window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)

//loading mcqueen
const loader = new GLTFLoader()
var mcqueen = new THREE.Object3D()
loader.load(
  './assets/mcqueen/scene.gltf',
  function (gltf) {
    mcqueen = gltf.scene
    gltf.scene.translateZ(-150)
    gltf.scene.translateY(0.5)
    gltf.scene.rotateY(Math.PI / 2)
    scene.add(gltf.scene)
  },
  function (xhr) {
    console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
  },
  function (error) {
    console.error(error)
  }
)

function createWheels () {
  const geometry = new THREE.BoxBufferGeometry(12, 12, 33)
  const material = new THREE.MeshLambertMaterial({ color: 0x333333 })
  const wheel = new THREE.Mesh(geometry, material)
  return wheel
}

function createCar (color) {
  const car = new THREE.Group()

  const backWheel = createWheels()
  backWheel.position.y = 6
  backWheel.position.x = -18
  car.add(backWheel)

  const frontWheel = createWheels()
  frontWheel.position.y = 6
  frontWheel.position.x = 18
  car.add(frontWheel)

  const main = new THREE.Mesh(
    new THREE.BoxBufferGeometry(60, 15, 30),
    new THREE.MeshLambertMaterial({ color: color })
  )
  main.position.y = 12
  car.add(main)

  const cabin = new THREE.Mesh(
    new THREE.BoxBufferGeometry(33, 12, 24),
    new THREE.MeshLambertMaterial({ color: 0xffffff })
  )
  cabin.position.x = -6
  cabin.position.y = 25.5
  car.add(cabin)
  return car
}

const car1 = createCar(0x78b14b)
car1.scale.multiplyScalar(0.2)
car1.position.set(-120, 0.5, 0)
car1.rotateY(Math.PI / 2)

const car2 = createCar(0x0000ff)
car2.scale.multiplyScalar(0.2)
car2.position.set(-160, 0.5, 0)
car2.rotateY(Math.PI / 2)

const car3 = createCar(0xff0500)
car3.scale.multiplyScalar(0.2)
car3.position.set(-200, 0.5, 0)
car3.rotateY(Math.PI / 2)

let radius1 = Math.sqrt(
  car1.position.x * car1.position.x + car1.position.z * car1.position.z
)
let radius2 = Math.sqrt(
  car2.position.x * car2.position.x + car2.position.z * car2.position.z
)
let radius3 = Math.sqrt(
  car3.position.x * car3.position.x + car3.position.z * car3.position.z
)

let angle = [0, 0, 0]
let cars = []
let stopped = [false, false, false]
let playerstopped = false
let delay = [5000, 6000, 7000]
let playerdelay = 1000
let lasthit = [Date.now(), Date.now(), Date.now()]
let playerlasthit = -1000

cars.push(car1)
cars.push(car2)
cars.push(car3)

scene.add(car1)
scene.add(car2)
scene.add(car3)

//lighting
var light = new THREE.AmbientLight(0xffffff) // soft white light
scene.add(light)
const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8)
directionalLight.position.set(200, 500, 300)
scene.add(directionalLight)
//track
const geometry = new THREE.RingGeometry(80, 270, 32)
const material = new THREE.MeshBasicMaterial({
  color: 0x000000,
  side: THREE.DoubleSide
})
geometry.rotateX(Math.PI / 2)
const mesh = new THREE.Mesh(geometry, material)
scene.add(mesh)

const newgeometry = new THREE.RingGeometry(0, 80, 32)
const newmaterial = new THREE.MeshBasicMaterial({
  color: 0x00ff00,
  side: THREE.DoubleSide
})
newgeometry.rotateX(Math.PI / 2)
const newmesh = new THREE.Mesh(newgeometry, newmaterial)
scene.add(newmesh)

//main loop
function animate () {
  time += 0.16
  if (gameover) {
    return
  }
  requestAnimationFrame(animate)
  Handlemovement()
  HandleText()
  updatecars()
  Handlecollision()
  addfuel()
  checkgameover()
  checkifinside()
  // stats.update()
  render()
}

function checkifinside () {
  let x = camera.position.x
  let z = camera.position.z
  let k = Math.sqrt(x * x + z * z)
  if (k > 260) {
    speed = 0
    camera.position.set(
      camera.position.x / 2,
      camera.position.y,
      camera.position.z / 2
    )
  }
  if (k < 80) {
    speed = 0
    camera.position.set(
      camera.position.x * 2,
      camera.position.y,
      camera.position.z * 2
    )
  }
}

function generateTable () {
  let playercar = {
    name: 'mcqueen',
    score: score
  }
  let blue = {
    name: 'dinoco',
    score: bluescore
  }
  let green = {
    name: 'chic-higgs',
    score: greenscore
  }
  let red = {
    name: 'cheaper mcqueen',
    score: redscore
  }
  let players = []
  players.push(playercar)
  players.push(blue)
  players.push(red)
  players.push(green)
  players.sort(function (x, y) {
    return x.score - y.score
  })
  players.reverse()
  // creates a <table> element and a <tbody> element
  const tbl = document.createElement('table')
  const tblBody = document.createElement('tbody')
  // creating all cells
  const header = document.createElement('tr')
  const headername = document.createElement('th')
  headername.appendChild(document.createTextNode('Name'))
  header.appendChild(headername)
  const headerscore = document.createElement('th')
  headerscore.appendChild(document.createTextNode('Score'))
  header.appendChild(headerscore)
  const headerrank = document.createElement('th')
  headerrank.appendChild(document.createTextNode('Ranking'))
  header.appendChild(headerrank)
  tbl.appendChild(header)
  for (let i = 0; i < 4; i++) {
    // creates a table row
    const row = document.createElement('tr')

    for (let j = 0; j < 3; j++) {
      // Create a <td> element and a text node, make the text
      // node the contents of the <td>, and put the <td> at
      // the end of the table row
      const cell = document.createElement('td')
      let cellText
      if (j == 0) {
        cellText = document.createTextNode(players[i].name)
      } else if (j == 1) {
        cellText = document.createTextNode(players[i].score.toString())
      } else {
        cellText = document.createTextNode((i + 1).toString())
      }
      cell.appendChild(cellText)
      row.appendChild(cell)
    }

    // add the row to the end of the table body

    tblBody.appendChild(row)
  }

  // put the <tbody> in the <table>
  tbl.appendChild(tblBody)
  // appends <table> into <body>
  document.body.appendChild(tbl)
  // sets the border attribute of tbl to '2'
  tbl.setAttribute('border', '2')
}

function checkgameover () {
  if (fuel <= 0) {
    renderer.setClearColor(0x000000, 1)
    document.getElementById('game').style.display = 'none'
    document.getElementById('fuelend').style.display = 'block'
    renderer.domElement.style.display = 'none'
    gameover = true
    generateTable()
  } else if (health <= 0) {
    renderer.setClearColor(0x000000, 1)
    document.getElementById('game').style.display = 'none'
    document.getElementById('healthend').style.display = 'block'
    renderer.domElement.style.display = 'none'
    generateTable()
    gameover = true
  }
  return
}

let cnt = 0
let cnt2 = 0
function Handlecollision () {
  let flag = 0
  for (let i = 0; i < cars.length; i++) {
    for (let j = 0; j < cars.length; j++) {
      if (i == j) continue
      if (stopped[i] == true || stopped[j] == true) continue
      if (Date.now() - lasthit[i] < 10000) continue
      if (Date.now() - lasthit[j] < 10000) continue
      if (
        Math.abs(cars[i].position.x - cars[j].position.x) < 20 &&
        Math.abs(cars[i].position.z - cars[j].position.z) < 3
      ) {
        cnt++
        // console.log(cnt + ': ' + 'collision')
        flag = 1
        lasthit[i] = Date.now()
        lasthit[j] = Date.now()
        stopped[i] = true
        stopped[j] = true
      }
    }
    if (playerstopped == true) continue
    if (Date.now() - playerlasthit < 10000) continue
    if (
      Math.abs(cars[i].position.x - mcqueen.position.x) < 15 &&
      Math.abs(cars[i].position.z - mcqueen.position.z) < 1.5
    ) {
      cnt2++
      playerlasthit = Date.now()
      playerstopped = true
      lasthit[i] = Date.now()
      stopped[i] = true
      health -= 20
    }
    if (delay[i] <= Date.now() - lasthit[i]) {
      stopped[i] = false
    }
  }
  if (playerdelay <= Date.now() - playerlasthit) playerstopped = false
  for (let i = 0; i < fuels.length; i++) {
    if (
      Math.abs(mcqueen.position.x - fuels[i].position.x) <= 12 &&
      Math.abs(mcqueen.position.z - fuels[i].position.z) <= 12
    ) {
      fuels[i].position.set(99999, 99999, 99999)
      fuel += 20
      score += 100
      fuelflag = false
    }
    for (let j = 0; j < cars.length; j++) {
      if (
        Math.abs(cars[j].position.x - fuels[i].position.x) <= 12 &&
        Math.abs(cars[j].position.z - fuels[i].position.z) <= 12
      ) {
        fuels[i].position.set(99999, 99999, 99999)
        // fuel += 20
        // score += 100
        fuelflag = false
        if (j == 0) greenscore += 100
        if (j == 1) bluescore += 100
        else if (j == 2) {
          redscore += 100
          redtoggle = -redtoggle
        }
      }
    }
  }
}
function addfuel () {
  if (fuels.length != 0) {
    let fuelposition = fuels[fuels.length - 1].position
    let xdifference = fuelposition.x - mcqueen.position.x
    let zdifference = fuelposition.z - mcqueen.position.z
    fueldistance = Math.sqrt(
      xdifference * xdifference + zdifference * zdifference
    )
  }
  if (fuelflag) return
  const tank = new THREE.Mesh(
    new THREE.BoxBufferGeometry(10, 10, 10),
    new THREE.MeshLambertMaterial({ color: 555555 })
  )
  let fuelradius = getRndInteger(100, 200)
  let fuelangle = Math.random() * Math.PI * 2
  tank.position.set(
    fuelradius * Math.sin(fuelangle),
    4.5,
    fuelradius * Math.cos(fuelangle)
  )
  scene.add(tank)
  fuels.push(tank)
  fuelflag = true
}
let car1initial = radius2
let car2initial = radius2
let radiusflag = 1
let random = 0
function updatecars () {
  if (!stopped[0]) {
    let last = angle[0]
    angle[0] += (Math.PI * 0.8) / 180
    let deltax = Math.cos(angle[0]) - Math.cos(last)
    let deltaz = Math.sin(angle[0]) - Math.sin(last)
    car1.position.set(
      car1.position.x - radius1 * deltax,
      car1.position.y,
      car1.position.z - radius1 * deltaz
    )
    car1.rotateY((-Math.PI * 0.8) / 180)
  }
  if (!stopped[1]) {
    if (radius2 >= car2initial * 1.2) radiusflag = -1
    else if (radius2 <= car2initial / 1.25) radiusflag = 1
    radius2 += radiusflag * 0.5
    let last = angle[1]
    angle[1] += (Math.PI * 0.8) / 180
    let deltax = Math.cos(angle[1]) - Math.cos(last)
    let deltaz = Math.sin(angle[1]) - Math.sin(last)
    car2.position.set(
      car2.position.x - radius2 * deltax,
      car2.position.y,
      car2.position.z - radius2 * deltaz
    )
    car2.rotateY((-Math.PI * 0.8) / 180)
  }
  if (!stopped[2]) {
    // radius3 = 1.5 * radius1 + 0.3 * radius1 * redtoggl
    let guess = Math.random() * 120
    if (guess < 1) random = Math.random() * 0.8 - 0.4
    let last = angle[2]
    angle[2] += (Math.PI * 0.8 * (1 + random)) / 180
    let deltax = Math.cos(angle[2]) - Math.cos(last)
    let deltaz = Math.sin(angle[2]) - Math.sin(last)
    car3.position.set(
      car3.position.x - radius3 * deltax,
      car3.position.y,
      car3.position.z - radius3 * deltaz
    )
    car3.rotateY((-Math.PI * 0.8 * (1 + random)) / 180)
  }
  // console.log(radius1, ': ', deltax, ': ', deltaz)
}

let insetHeight = window.innerHeight / 4
let insetWidth = window.innerWidth / 4
function render () {
  renderer.setViewport(0, 0, window.innerWidth, window.innerHeight)
  renderer.render(scene, camera)
  renderer.clearDepth()
  renderer.setScissorTest(true)
  renderer.setScissor(
    window.innerWidth - insetWidth - 16,
    window.innerHeight - insetHeight - 16,
    insetWidth,
    insetHeight
  )
  renderer.setViewport(
    window.innerWidth - insetWidth - 16,
    window.innerHeight - insetHeight - 16,
    insetWidth,
    insetHeight
  )
  renderer.render(scene, cameraTop)
  renderer.setScissorTest(false)
}

// animate()

//texthandler
function HandleText () {
  document.getElementById('info').innerHTML =
    'Fuel: ' + Math.trunc(fuel).toString()
  document.getElementById('speed').innerHTML =
    'speed:' + Math.trunc(speed * 100).toString()
  document.getElementById('health').innerHTML =
    'health: ' + Math.trunc(health).toString()
  document.getElementById('fueldistance').innerHTML =
    'Distance to fuel: ' + Math.trunc(fueldistance).toString()
  document.getElementById('time').innerHTML =
    'time: ' + Math.trunc(time).toString()
  document.getElementById('score').innerHTML =
    'score: ' + Math.trunc(score).toString()
  document.getElementById('bluescore').innerHTML =
    'bluescore: ' + Math.trunc(bluescore).toString()
  document.getElementById('greenscore').innerHTML =
    'greenscore: ' + Math.trunc(greenscore).toString()
  document.getElementById('redscore').innerHTML =
    'redscore: ' + Math.trunc(redscore).toString()
  document.getElementById('mileage').innerHTML =
    'mileage: ' + Math.trunc(distance / consumed).toString()
}

//checking for input

document.getElementById('myBtn').addEventListener('click', start)

function start () {
  document.getElementById('game').style.display = 'block'
  document.getElementById('main').style.display = 'none'
  makeaudience()
  animate()
}

const texture = new THREE.TextureLoader().load(
  './assets/textures/crowd-texture.jpg'
)

// immediately use the texture for material creation
const crowdmaterial = new THREE.MeshBasicMaterial({ map: texture })
function makeaudience () {
  let angle = 0
  for (let i = 0; i < 20; i++) {
    const box = new THREE.BoxGeometry(100, 100, 100)
    const cube = new THREE.Mesh(box, crowdmaterial)
    cube.position.set(350 * Math.sin(angle), 5, 350 * Math.cos(angle))
    scene.add(cube)
    cube.rotateY(angle)
    angle += (Math.PI * 2) / 20
  }
}

addEventListener('keydown', event => {
  if (event.key === ' ') {
    keys.space = true
    console.log('space')
  }
  if (event.key === 'w') {
    keys.w = true
  }
  if (event.key === 's') {
    keys.s = true
  }
  if (event.key === 'a') {
    keys.a = true
  }
  if (event.key === 'd') {
    keys.d = true
  }
  if (event.key === 'r') {
    keys.r = 1 - keys.r
    let temp = new THREE.Vector3()
    temp.copy(camera.position)
    if (keys.r == 0) {
      camera.position.x = mcqueen.position.x
      camera.position.y = mcqueen.position.y
    } else {
      var cwd = new THREE.Vector3()
      mcqueen.getWorldDirection(cwd)
      var dist = -20
      var cwd = new THREE.Vector3()
      mcqueen.getWorldDirection(cwd)
      cwd.multiplyScalar(dist)
      cwd.add(camera.position)
      camera.position.set(cwd.x, 10, cwd.z)
    }
    // cameraTop.position.x = temp.x
    // cameraTop.position.y = 50
    // cameraTop.position.z = temp.z
  }
})

addEventListener('keyup', event => {
  if (event.key === 'w') {
    keys.w = false
  }
  if (event.key === 's') {
    keys.s = false
  }
  if (event.key === 'a') {
    keys.a = false
  }
  if (event.key === 'd') {
    keys.d = false
  }
})

//calculates the movement
function Handlemovement () {
  let isaccelarating = false
  let isturning = false
  let cameradirection = new THREE.Vector3()
  let topspeed = 10
  let rotation = 0
  camera.getWorldDirection(cameradirection)
  if (keys.w) {
    isaccelarating = true
    if (speed <= topspeed) speed += 0.05 * (1 - speed / topspeed)
    fuel -= 0.1
    consumed += 0.1
  }
  if (keys.s) {
    isaccelarating = true
    if (speed >= -topspeed) speed -= 0.05 * (1 - speed / topspeed)
    fuel -= 0.1
    consumed += 0.1
  }
  if (keys.a) {
    rotation = (Math.PI * 3) / (1 + Math.abs(speed)) / 180
    isturning = true
    if (turnangle < 1) turnangle += 0.2
  }
  if (keys.d) {
    rotation = (-Math.PI * 3) / (1 + Math.abs(speed)) / 180
    if (speed < 1) rotation /= 2 - speed
    isturning = true
    if (turnangle > -1) turnangle -= 0.2
  }
  if (isturning == false) turnangle /= 1.1
  if (!isaccelarating) {
    speed /= 1.04
    if (speed < 100) speed /= 1.04
    if (speed < 0.01) speed = 0
  }
  if (playerstopped) speed = 0
  distance += speed
  camera.position.x += speed * cameradirection.x
  camera.position.z += speed * cameradirection.z
  if (speed) camera.rotation.y += rotation
  if (!speed) turnangle = 0
  //positioning mcqueen
  if (keys.r) {
    camera.position.y = 10
    var dist = 20
    var cwd = new THREE.Vector3()
    camera.getWorldDirection(cwd)
    cwd.multiplyScalar(dist)
    cwd.add(camera.position)
    mcqueen.position.set(cwd.x, 0.5, cwd.z)
    mcqueen.setRotationFromQuaternion(camera.quaternion)
    mcqueen.rotateY(Math.PI + (turnangle * 0.5) / (1 + Math.abs(speed)))
  } else {
    camera.position.y = 6
    mcqueen.position.set(camera.position.x, 0.5, camera.position.z)
    mcqueen.setRotationFromQuaternion(camera.quaternion)

    mcqueen.rotateY(Math.PI + (turnangle * 0.5) / (1 + Math.abs(speed)))
    // console.log('camera')
    // console.log(camera.position)
  }
  // cameraTop.position.set(cwd.x, 5, cwd.z)
  // cameraTop.lookAt(mcqueen.position)
}
