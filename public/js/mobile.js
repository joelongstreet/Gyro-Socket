(function() {

  $(function() {
    return $('.btn').click(function() {
      var player, prev_alpha, prev_beta, rando, socket;
      socket = io.connect('/');
      rando = Math.floor(Math.random() * 16777215).toString(16);
      player = {
        name: $('input').val(),
        uid: rando,
        color: '#' + rando
      };
      socket.emit('player_connect', player);
      $('#sign_up').hide();
      $('#color').css('background-color', player.color);
      $('#name').text(player.name);
      prev_alpha = 0;
      prev_beta = 0;
      return window.ondeviceorientation = function(e) {
        if (Math.round(e.alpha) !== prev_alpha) {
          socket.emit("alpha_update_" + player.uid, e.alpha);
        }
        if (Math.round(e.beta) !== prev_beta) {
          socket.emit("beta_update_" + player.uid, e.beta);
        }
        prev_alpha = Math.round(e.alpha);
        return prev_beta = Math.round(e.beta);
      };
    });
  });

}).call(this);
