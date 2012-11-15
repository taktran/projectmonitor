describe('ProjectRefresh.init', function() {
  beforeEach(function() {
    var fixtures = [
      "<ul class='projects'>",
        "<li class='project success' id='project_1' data-id='1'></li>",
        "<li class='project failure' id='project_2' data-id='2'></li>",
        "<li class='project failure' id='project_3' data-id='3'></li>",
        "<li class='project aggregate success' id='aggregate_project_4' data-id='4'>Aggregate Project</li>",
      "</ul>"
    ].join("\n");
    setFixtures(fixtures);
    jasmine.Clock.useMock();
  });

  describe("updateTile", function() {
    beforeEach(function() {
      $("body").addClass("dashboard").data("tiles-count", "48");
      ajaxRequests = [];
    });

    it("should replace the project tile with the given data", function() {
      ProjectRefresh.updateTile("project_3",
                                "<li class='project failure' id='project_3' data-id='3'>UPDATED</li>");

      expect($('#project_3').text()).toBe('UPDATED');
    });
  });
});

