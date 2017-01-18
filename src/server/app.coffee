http     = require "http"
socketio = require "socket.io"
mongoose = require "mongoose"

server  = http.createServer null
Service = require "./db/models/service-model"

io           = socketio.listen server
mongoAddress = "mongodb://localhost:27017/Services"
mongoose.connect mongoAddress

# init mongo status logging
db = mongoose.connection
db.on 'connected', ->
  console.info "connected to mongodb"
db.on 'connecting', ->
  console.info "connecting to mongodb"
db.on 'error', (err) ->
  console.info "error connecting to mongodb"
  console.error err
db.on 'disconnected', ->
  console.info "disconnected from mongodb"

# listen for incoming socket connections
io.on "connection", (socket) ->
  console.info "socket connected"
  socket.on "disconnect", ->
    console.info "socket disconnected"
    if(socket.isService)
      console.info "service-down", socket.name, socket.port

  socket.on "service-up", (data) ->
    # this socket is a service
    socket.isService = true
    socket.name      = data.name
    socket.port      = data.port
    console.info "service-up", data.name, data.port

# we need a static port for our services to connect to it
server.listen 3001

# check existing services in db on start up...
# but this means that if a service came up when
# we were down, it will not be saved in the db
# we will not allow services to be created without connection to the
# service registry

console.info "Listening on port", server.address().port
