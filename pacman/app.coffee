express = require('express')
routes = require('./routes')

app = module.exports = express.createServer()
io = require('socket.io').listen(app)

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.compiler
    src: __dirname + '/client'
    dest: __dirname + '/cache'
    enable: ['coffeescript']
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use require('stylus').middleware(
    src: __dirname + '/client'
    dest: __dirname + '/cache'
    compress: true
  )
  app.use express.static(__dirname + '/public')
  app.use express.static(__dirname + '/cache')

app.configure 'development', ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure 'production', ->
  app.use express.errorHandler()

app.get '/', routes.index

nextPlayer = 0
players = [false, false, false, false, false]

io.sockets.on 'connection', (socket) =>
  if players[4] is false
    player = 4
  else 
    i = 0
    while players[i] is true
      i++ 
    player = i

  players[player] = true

  socket.emit 'set_player', player

  socket.on 'disconnect', =>
    players[player] = false

  socket.on 'player_direction', (data) =>
    time = new Date()
    time = time.getTime()
    data.time = time

    io.sockets.emit 'player_direction', data
    console.log data.playerObj

  socket.on 'gameSwitchState', (data) ->
    io.sockets.emit 'gameSwitchState', data

app.listen 3000
console.log 'Express server listening on port %d in %s mode', app.address().port, app.settings.env

