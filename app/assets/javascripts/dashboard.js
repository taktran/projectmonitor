//= require versionCheck
//= require projectCheck
//= require githubRefresh
//= require herokuRefresh
//= require rubygemsRefresh

$(function() {
  VersionCheck.init();
  ProjectCheck.init();
  GithubRefresh.init();
  HerokuRefresh.init();
  RubyGemsRefresh.init();

  $(document).bind("ajaxStart", function() {
    $('#indicator').removeClass('idle');
  });

  $(document).bind("ajaxStop", function() {
    $('#indicator').addClass('idle');
  });
});
