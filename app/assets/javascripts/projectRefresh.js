var ProjectRefresh = (function () {

  var tilesCount = 15,
    fadeIntervalSeconds = 3, 
    faye;

  function showAsBuilding (projectSelector) {
    var $projectEl = $(projectSelector);
    (function f(i) {
      if (i < (pollIntervalSeconds / fadeIntervalSeconds) - 1) {
        $projectEl.fadeTo(1000, 0.5).fadeTo(1000, 1);
        setTimeout(function() {
          f(i + 1);
        }, fadeIntervalSeconds * 1000);
      }
    })(0);
  }

  return {
    init : function () {
      tilesCount = parseInt($('body').data('tiles-count'), 10);

      $('li.building').each(function (i, li) {
        showAsBuilding(li);
      });

      faye = new Faye.Client('http://localhost:9292/faye');
      $.map($('.project'), function(projectElement) {
        var id = $(projectElement).data('id');
        faye.subscribe('/projects/' + id, function (data) {
          $projectEl = $('#project_' + id).replaceWith(data);
          if ($projectEl.hasClass('building')) {
            showAsBuilding(projectSelector);
          }
        });
      });
    }
  };
})();
