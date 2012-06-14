socket   = io.connect('/')
my_balls = []
message_content = []
$ ->
    
    message_content     = $('.messages').find('.container')
    
    $('.player').each ->
        player          = {}
        player.uid      = $(@).find('.uid').text()
        player.name     = $(@).find('.name').text()
        player.color    = $(@).find('.color').text()
        ball            = new Ball player
        my_balls.push ball

    socket.on 'create_ball', (data) ->
        ball = new Ball data
        my_balls.push ball

    socket.on 'remove_ball', (uid) ->
        for ball in my_balls
            if ball.uid == uid
                ball.dom.fadeOut()

    
class Ball
    
    constructor : (data) ->

        @dom = []
        @uid = data.uid

        x_offset = 400
        y_offset = 300

        x_sensitivity = 10
        y_sensitivity = 50

        @dom = $("<div class='ball' style='background-color:#{data.color}'>#{data.name}</div>")
        $('body').append(@dom)

        socket.on "update_y_#{data.uid}", (pos) =>
            @dom.css 'top', -1*pos*x_sensitivity + x_offset

        socket.on "update_x_#{data.uid}", (pos) =>
            if pos > 180
                new_y = ((360 - pos)/360)*100
            else
                new_y = (pos/360*-1)*100
            @dom.css 'left', new_y*y_sensitivity + y_offset

        socket.on "new_message_#{data.uid}", (message) =>
            template = "<li><span class='user'>#{data.name}</span><span class='message'>#{message}</span></li>"
            message_content.append(template)

