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

  $('#search_btn').click(function() {
    var term = $("#search_term").val();
    if (term.trim().length == 0) {
      showError("Empty search term");
      return
    }
    var limit = $("#limit").val();
    setProgress(0);

    $.post('/search', { 'query' : term, 'limit' : limit }, function(data) {
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
});
