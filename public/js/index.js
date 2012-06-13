(function() {
  var Ball, my_balls, socket;

  socket = io.connect('/');

  my_balls = [];

  $(function() {
    $('.player').each(function() {
      var ball, player;
      player = {};
      player.uid = $(this).find('.uid').text();
      player.name = $(this).find('.name').text();
      player.color = $(this).find('.color').text();
      ball = new Ball(player);
      return my_balls.push(ball);
    });
    socket.on('create_ball', function(data) {
      var ball;
      ball = new Ball(data);
      return my_balls.push(ball);
    });
    return socket.on('remove_ball', function(uid) {
      var ball, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = my_balls.length; _i < _len; _i++) {
        ball = my_balls[_i];
        if (ball.uid === uid) {
          _results.push(ball.dom.fadeOut());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
  });

  Ball = (function() {

    function Ball(data) {
      var x_offset, x_sensitivity, y_offset, y_sensitivity,
        _this = this;
      this.dom = [];
      this.uid = data.uid;
      x_offset = 400;
      y_offset = 300;
      x_sensitivity = 10;
      y_sensitivity = 50;
      this.dom = $("<div class='ball' style='background-color:" + data.color + "'>" + data.name + "</div>");
      $('body').append(this.dom);
      socket.on("update_y_" + data.uid, function(pos) {
        return _this.dom.css('top', -1 * pos * x_sensitivity + x_offset);
      });
      socket.on("update_x_" + data.uid, function(pos) {
        var new_y;
        if (pos > 180) {
          new_y = ((360 - pos) / 360) * 100;
        } else {
          new_y = (pos / 360 * -1) * 100;
        }
        return _this.dom.css('left', new_y * y_sensitivity + y_offset);
      });
    }

    return Ball;

  })();

}).call(this);
