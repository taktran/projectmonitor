describe "ProjectMonitor.Views.HomeView", ->
  beforeEach ->
    projects = new ProjectMonitor.Collections.Projects([BackboneFactory.create('aggregate_project'), BackboneFactory.create('project')])
    @view = new ProjectMonitor.Views.HomeView(collection: projects)

  it "should render two tile", ->
    expect(@view.render().$el.find("article").length).toEqual(2)

  it "should render aggregate tile", ->
    expect(@view.render().$el).toContain("li.aggregate")

  it "should render standalong tile", ->
    expect(@view.render().$el).toContain("li.project")
