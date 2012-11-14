//= require application
//= require versionCheck
//= require projectCheck
//= require projectRefresh
//= require githubRefresh

$(function() {
  VersionCheck.init();
  ProjectCheck.init();
  ProjectRefresh.init();
  GithubRefresh.init();

  $(document).bind("ajaxStart", function() {
    $('#indicator').removeClass('idle');
  });

  $(document).bind("ajaxStop", function() {
    $('#indicator').addClass('idle');
  });

  // var faye = new Faye.Client('http://localhost:9292/faye');
  // projectSelectors = $.map($('.project'), function(projectElement) {
    // var id = $(projectElement).data('id');
    // faye.subscribe('/projects/' + id, function (data) {
      // console.log(data);
      // $projectEl = $('#project_' + id).replaceWith(data);
      // // if ($projectEl.hasClass('building')) {
        // // showAsBuilding(projectSelector);
      // // }
    // });
  // });
});
