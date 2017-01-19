# Node Service Registry

## WIP

### About
An assignment for a job opening.  
Starts on port 3001 and listens for incomming socket.io connections.  
Because it's running on a fixed port other services can always find it.  
If a connecting socket is a service (by emitting 'service-up' with it's service name after it connects)  
We add it to a list of running services.  
Other sockets can now subscribe to these services by their service name.  
When a new service comes up, all the subscribed sockets will get notified of its location.  
So they can connect to them directly.  

### Screenshots
Service Registry running, bottom-right.  
64 person-generators up.  
1 socket (web-server, bottom-left) subscribed to 'person-generator'  
<img src="https://github.com/stofstik/service-registry/blob/master/screenshot-1.png" alt="screenshot" width="1024px"/>  

### Installation
- `npm install -g gulp`
- `npm install`
- `gulp`

### Configuration
Ideally you would have systemd start this service on OS boot, and on service crash.  
./service-registry.service provides a basic configuration to do just that.
