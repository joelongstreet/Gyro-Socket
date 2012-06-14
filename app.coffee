express     = require 'express'
path        = require 'path'
stylus      = require 'stylus'
app         = express.createServer()
port        = process.env.PORT || 3000
env         = process.env.environment || 'development'
io          = require('socket.io').listen app
players     = []

io.settings.logger.level = 0

app.configure ->
    app.use express.static path.join __dirname, 'public'
    app.use stylus.middleware
        debug: true 
        force: true
        src: "#{__dirname}/public"
        dest: "#{__dirname}/public"
    app.set 'views', path.join __dirname, 'public/views'
    app.set 'view engine', 'jade'


app.get '/', (req, res) ->
    user_agent = req.headers['user-agent']
    if /mobile/i.test user_agent then res.render 'mobile'
    else
        res.render 'index', players : players

app.get '/mobile', (req, res) ->
    res.render 'mobile'

app.get '/listen', (req, res) ->
    res.render 'index', players : players
    

io.sockets.on 'connection', (socket) ->
    socket.on 'player_connect', (data) ->

        player =
            uid  : data.uid
            name : data.name
            color: data.color

        players.push player

        socket.broadcast.emit 'create_ball', player

        socket.on "alpha_update_#{player.uid}", (pos) ->
            socket.broadcast.emit "update_x_#{player.uid}", pos

        socket.on "beta_update_#{player.uid}", (pos) ->
            socket.broadcast.emit "update_y_#{player.uid}", pos

        socket.on "message_#{player.uid}", (message) ->
            socket.broadcast.emit "new_message_#{player.uid}", message

        socket.on 'error', ->
            for unit in players
                if unit.uid == player.uid
                    players.splice _i, 1
            socket.broadcast.emit 'remove_ball', player.uid

        socket.on 'disconnect', ->
            for unit in players
                if unit.uid == player.uid
                    players.splice _i, 1
            socket.broadcast.emit 'remove_ball', player.uid


app.listen port