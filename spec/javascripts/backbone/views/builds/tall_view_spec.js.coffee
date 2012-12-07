describe "ProjectMonitor.Views.Builds.TallView", ->
  beforeEach ->
    @build = new ProjectMonitor.Models.Build {name: 'Project Monitor', statuses: [true, false, true], last_build: '4d'}
    @view = new ProjectMonitor.Views.Builds.TallView {model: @build}
    @$html = @view.render().$el

  it "should include the name", ->
    expect(@$html.find(".name")).toHaveText(@build.get("name"))

  it "should include the history", ->
    expect(@$html.find(".statuses li:nth-child(1)")).toHaveClass("success")
    expect(@$html.find(".statuses li:nth-child(2)")).toHaveClass("failure")
    expect(@$html.find(".statuses li:nth-child(3)")).toHaveClass("success")

  it "should include the time", ->
    expect(@$html.find(".last-build")).toHaveText("4d")

  describe "status", ->
    describe "when the build succeeded", ->
      beforeEach ->
        @build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: '4d', success: true}
        @view = new ProjectMonitor.Views.Builds.LargeView {model: @build}
        @$html = @view.render().$el

      it "should have success class", ->
        expect(@$html.find(".build")).toHaveClass("success")

    describe "when the build failed", ->
      beforeEach ->
        @build = new ProjectMonitor.Models.Build {name: 'Project Monitor', aggregate: false, statuses: [true, false, true], last_build: '4d', success: false}
        @view = new ProjectMonitor.Views.Builds.TallView {model: @build}
        @$html = @view.render().$el

      it "should have failed class", ->
        expect(@$html.find(".build")).toHaveClass("failure")
