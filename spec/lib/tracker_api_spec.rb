require 'spec_helper'

describe TrackerApi do
  it 'can retrieve the velocities for previous iterations'do
    project = stub(:project)
    PivotalTracker::Project.stub(:find).with(1234) { project }
    PivotalTracker::Iteration.stub(:done).with(project, offset: -2) do
      [
        stub(:iteration_1, stories: [stub(estimate: 1), stub(estimate: 2)]),
        stub(:iteration_2, stories: [stub(estimate: 3), stub(estimate: 4)])
      ]
    end
    velocities = TrackerApi.new(:auth_token, 1234).previous_iterations_velocities(2)
    velocities.should == [3, 7]
  end
end
