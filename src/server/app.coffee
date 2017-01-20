http     = require "http"
socketio = require "socket.io"
express  = require "express"

app    = express()
server = http.createServer app
io     = socketio.listen server

# contains all connected services as { "service-name": [ service1, service2 ] }
services = {}
# contains all sockets
sockets = []

# returns an array of sockets containing serviceName in their subscription array
subscribedSockets = (serviceName) ->
  return sockets.filter (s) ->
    return s.subscriptions.indexOf(serviceName) != -1

# listen for incoming socket connections
io.on "connection", (socket) ->
  console.info "socket connected"
  # contains all services this socket is subscribed to
  socket.subscriptions = []
  # add socket to array so we can keep track of it
  sockets.push socket

  socket.on "disconnect", ->
    console.info "socket disconnected"
    # remove dead socket from sockets array
    sockets.splice sockets.indexOf(socket), 1
    if(socket.isService)
      # socket was a service remove it from the services array
      services[socket.name].splice services[socket.name].indexOf(socket), 1
      # log some stuffs
      console.info "service down, #{socket.name}:#{socket.port}"
      console.info "#{services[socket.name].length} #{socket.name}(s) active"

  socket.on "service-up", (service) ->
    # this socket is a service
    socket.isService = true
    # set some reference data
    socket.name      = service.name
    socket.port      = service.port
    # add service to services object
    if(services[service.name])
      # key with this service name already exists in the services object
      services[service.name].push socket
    else
      # key with this service name does not exist yet
      # add it and put this service in an array as its value
      services[service.name] = [ socket ]

    # log some info
    console.info "service up, #{service.name}:#{service.port}"
    console.info "#{services[service.name].length} #{service.name}(s) active,
      #{subscribedSockets(service.name).length} subscribed"

    # tell all subscribed sockets a new service is up
    for subscriber in subscribedSockets service.name
      subscriber.emit "service-up", {name: service.name, port: service.port}

  socket.on "subscribe-to", (data) ->
    console.log "socket subscribing to #{data.name}"
    socket.subscriptions.push data.name
    console.info "#{subscribedSockets(data.name).length} socket(s)
      subscibed to #{data.name}s"
    # tell subscriber the current services it subscribed to
    for subscriber in subscribedSockets data.name
      # check if there are any
      if(!services[data.name])
        return
      for service in services[data.name]
        subscriber.emit "service-up", {name: service.name, port: service.port}

# Returns the port of each running service in a json array
# TODO check if service that is requesting is subscribed?
app
  .get "/getInstancesByServiceName/:serviceName", (req, res) ->
    if(!services[req.params.serviceName])
      return res.json err: 'not-found'
    res.json services[req.params.serviceName].map (s) ->
      return {name: s.name, port: s.port}

# we need a static port for our services to connect to it
server.listen 3001
console.info "Listening on port", server.address().port
