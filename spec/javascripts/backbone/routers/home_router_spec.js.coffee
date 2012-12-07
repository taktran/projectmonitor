describe "ProjectMonitor.Routers.HomeRouter", ->
  beforeEach ->
    spyOn(ProjectMonitor.Routers.HomeRouter.prototype, "index")
    @router = new ProjectMonitor.Routers.HomeRouter();
    try
      Backbone.history.start()
    catch e

  afterEach ->
    Backbone.history.stop()

  it "should call index callback", ->
    @router.navigate("home", true)
    expect(ProjectMonitor.Routers.HomeRouter.prototype.index).toHaveBeenCalled()
