$(function() {
  var setProgress = function(progress, visible) {
    var visible = (visible === undefined) ? true : visible;
    var container = $('.js-progress-container');
    var search = $('.js-search-container');
    if (visible) {
      container.removeClass("hidden");
      search.addClass("hidden");
      clearAlert();
    } else {
      container.addClass("hidden");
      search.removeClass("hidden");
    }
    container.find('.progress-bar')
      .attr('aria-valuenow', progress)
      .attr('style', 'width: ' + progress + '%')
      .text(progress + '%');
  };

  var clearAlert = function() {
    $('#alert').addClass("hidden");
  }

  var showError = function(message) {
    $('#alert')
      .removeClass("hidden")
      .removeClass("alert-info")
      .removeClass("alert-success")
      .addClass("alert-danger")
      .text(message);
  };

  var showInfo = function(message) {
    $('#alert')
      .removeClass("hidden")
      .removeClass("alert-danger")
      .removeClass("alert-success")
      .addClass("alert-info")
      .text(message);
  };

  var showSuccess = function(message) {
    $('#alert')
      .removeClass("hidden")
      .removeClass("alert-danger")
      .removeClass("alert-info")
      .addClass("alert-success")
      .text(message);
  };

  $('#mail_to').blur(function() {
    destination = $(this).val().trim();
    if (destination && destination.length > 0 && typeof(Storage) !== "undefined") {
      localStorage.setItem("mail_to", destination);
    }
  });

  $('#search_btn').click(function() {
    var term = $("#search_term").val();
    if (term.trim().length == 0) {
      showError("Empty search term");
      return;
    }
    var limit = $("#limit").val();
    var blacklist = $("#blacklist").val();
    var mail_to = $("#mail_to").val();
    if (mail_to.trim().length == 0) {
      showError("Empty destination email");
      return;
    }
    setProgress(0);

    $.post('/search', { 'query' : term, 'mail_to' : mail_to, 'blacklist' : blacklist, 'limit' : limit }, function(data) {
      var timer = setInterval(function() {
        $.get('/status/' + data['pid'], function(d) {
          if (d['status'] == 'queued' || d['status'] == 'working') {
            setProgress(d['progress']);
            showInfo(d['message']);
            return;
          }

          clearInterval(timer);
          setProgress(0, false);
          if (d['status'] == 'complete') {
            showSuccess(d['message']);
          } else {
            showError(d['message']);
          }
        });
      }, 1000);
    });
  });

  if(typeof(Storage) !== "undefined") {
    $('#mail_to').val(localStorage.getItem("mail_to"));
  };
});
