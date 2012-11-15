var ProjectRefresh = (function () {

  var tilesCount = 15,
    fadeIntervalSeconds = 10,
    faye;

  function showAsBuilding (projectSelector) {
    var $projectEl = $(projectSelector);
    (function f(i) {
      if (i < (fadeIntervalSeconds) - 1) {
        $projectEl.fadeTo(1000, 0.5).fadeTo(1000, 1);
        setTimeout(function() {
          f(i + 1);
        }, fadeIntervalSeconds * 1000);
      }
    })(0);
  }

  return {
    updateTile: function(channel, data) {
      $projectEl = $('#' + channel).replaceWith(data);
      if($projectEl.hasClass('building')) {
        showAsBuilding(projectSelector);
      }
    },
    init: function () {
      tilesCount = parseInt($('body').data('tiles-count'), 10);

      $('li.building').each(function (i, li) {
        showAsBuilding(li);
      });

      faye = new Faye.Client('http://localhost:9292/faye');
      $.map($('.project'), function(projectElement) {
        var id = $(projectElement).data('id');
        var projectType = 'project';
        if($(projectElement).hasClass('aggregate')) {
          projectType = 'aggregate_project';
        }
        var channel = projectType + "_" + id;
        faye.subscribe("/refresh/" + channel, function (data) {
          alert(data);
          ProjectRefresh.updateTile(channel, data);
        });
      });
    }
  };
})();
