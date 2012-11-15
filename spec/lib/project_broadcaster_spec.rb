require 'spec_helper'


describe ProjectBroadcaster do
  describe ".broadcast_update" do
    # NOTE: The FactoryGirl.create triggers a broadcast_update, so each test
    # scenario should account for this extra broadcast.
    let(:project) { FactoryGirl.create(:jenkins_project) }
    let(:aggregate_project) { FactoryGirl.create(:aggregate_project) }
    let(:uri) { URI.parse("http://127.0.0.1:9292/faye") }


    context "for project" do
      it "broadcasts the partial to the project's channel" do
        Net::HTTP.should_receive(:post_form).exactly(2).times
          .with(uri, message: include("\"channel\":\"/refresh/project_#{project.id}\""))
        ProjectBroadcaster.broadcast_update(project)
      end
    end
    context "for aggregate project" do
      it "broadcasts the partial to the aggregate's channel" do
        Net::HTTP.should_receive(:post_form).exactly(2).times
          .with(uri, message: include("\"channel\":\"/refresh/aggregate_project_#{aggregate_project.id}\""))
        ProjectBroadcaster.broadcast_update(aggregate_project)
      end
    end
    context "for project with aggregate project" do
      it "broadcasts the partial to the project's channel and the aggregate's channel" do
        Net::HTTP.should_receive(:post_form).exactly(2).times #PROJ
          .with(uri, message: include("\"channel\":\"/refresh/project_#{project.id}\""))
        Net::HTTP.should_receive(:post_form).exactly(2).times #AGG PROJ
          .with(uri, message: include("\"channel\":\"/refresh/aggregate_project_#{aggregate_project.id}\""))
        project.aggregate_project = aggregate_project
        ProjectBroadcaster.broadcast_update(project)
      end
    end
  end
end
