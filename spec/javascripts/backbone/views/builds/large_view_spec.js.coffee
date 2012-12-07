describe "ProjectMonitor.Views.Builds.LargeView", ->
  describe "build", ->
    beforeEach ->
      @build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: '4d'}
      @view = new ProjectMonitor.Views.Builds.LargeView {model: @build}
      @$html = @view.render().$el

    it "should include the name", ->
      expect(@$html.find(".name")).toHaveText(@build.get("name"))

    it "should include the history", ->
      expect(@$html.find(".statuses li:nth-child(1)")).toHaveClass("success")
      expect(@$html.find(".statuses li:nth-child(2)")).toHaveClass("failure")
      expect(@$html.find(".statuses li:nth-child(3)")).toHaveClass("success")

    it "should include the last build time", ->
      expect(@$html.find(".last-build")).toHaveText("4d")

  describe "aggregate", ->
    beforeEach ->
      @build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: true}
      @view = new ProjectMonitor.Views.Builds.LargeView {model: @build}
      @$html = @view.render().$el

    it "should include the name", ->
      expect(@$html.find(".name")).toHaveText(@build.get("name"))

    it "should not include the history", ->
      expect(@$html).not.toContain(".history")
