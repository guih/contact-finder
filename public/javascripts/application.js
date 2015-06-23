$(function() {
  var setProgress = function(progress, visible) {
    var visible = (visible === undefined) ? true : visible;
    var container = $('.js-progress-container');
    var search = $('.js-search-container');
    if (visible) {
      container.removeClass("hidden");
      search.addClass("hidden");
      $('#download_btn').addClass("hidden");
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
      .addClass("alert-danger")
      .text(message);
  };

  var showInfo = function(message) {
    $('#alert')
      .removeClass("hidden")
      .removeClass("alert-danger")
      .addClass("alert-info")
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
            $('#download_btn')
              .removeClass("hidden")
              .attr('href', '/download/' + data['file_name'])
              .html('<span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> ' + data['file_name']);
          } else {
            showError(d['message']);
          }
        });
      }, 1000);
    });
  });
});
