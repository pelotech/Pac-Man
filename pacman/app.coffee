express = require('express')

app = module.exports = express.createServer()
io = require('socket.io').listen(app)

PACMAN = 4
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

games = {}
# openGame = 0
# games[openGame].players = [false, false, false, false, false]

app.get '/', (req, res)->
  getOpenGame (gameId) =>
    generateSocket gameId, ->
      res.render 'index', title: 'Pac-Man', game:gameId
  
app.get '/:gameId', (req, res) ->
  res.render 'index', title: 'Express' 

getOpenGame = (cb) ->
  cb 0

generateSocket = (id, cb) ->
  if games[id] then return cb games[id]
  game = games[id] = {}
  ions = game.ions = io.of("/#{id}")
  cb game
  players = games[id].players = [false, false, false, false, false]
  ions.on 'connection', (socket) =>  
      console.log "Foo"
      if players[PACMAN] is false
        player = PACMAN
      else
        i = 0
        while players[i] is true
          i++ 
        player = i

      players[player] = true

      socket.emit 'set_player', player
      ions.emit 'set_players', players

      socket.on 'disconnect', =>
        players[player] = false
        ions.emit 'set_players', players
        if players[4] is false
          gameState = 'menuState'

      socket.on 'player_direction', (data) =>
        time = new Date()
        time = time.getTime()
        data.time = time

        ions.emit 'player_direction', data

      socket.on 'newGame', () ->
        ions.emit 'newGame'

app.listen 3000
console.log 'Express server listening on port %d in %s mode', app.address()?.port, app.settings.env