require 'spec_helper'

describe TrackerProjectValidator do
  describe "validate" do
    let(:params) { {auth_token: auth_token, project_id: project_id} }

    subject { TrackerProjectValidator::Job.new(params).perform }

    context "with a valid token and valid project id" do
      let(:auth_token) { '881c7bc3264a00d280225ea409225fe8' }
      let(:project_id) { '590337' }

      before do
        PivotalTracker::Project.stub(:find).with(project_id) { true }
      end

      it { should == :ok }
    end

    context "with an invalid token and valid project id" do
      let(:auth_token) { '837458265' }
      let(:project_id) { '590337' }

      before do
        PivotalTracker::Project.stub(:find).with(project_id) { raise RestClient::Unauthorized }
      end

      it { should == :unauthorized}
    end

    context "with a valid token and invalid project id" do
      let(:auth_token) { '881c7bc3264a00d280225ea409225fe8' }
      let(:project_id) { '935729729' }

      before do
        PivotalTracker::Project.stub(:find).with(project_id) { raise RestClient::ResourceNotFound }
      end

      it { should == :not_found }
    end

    context "with a invalid token and invalid project id" do
      let(:auth_token) { '837458265' }
      let(:project_id) { '397295725' }

      before do
        PivotalTracker::Project.stub(:find).with(project_id) { raise RestClient::Unauthorized }
      end

      it { should == :unauthorized }
    end

    describe "enqueuing a delayed job" do
      let(:auth_token) { '881c7bc3264a00d280225ea409225fe8' }
      let(:project_id) { '590337' }

      it "should enqueue a job" do
        Delayed::Job.should_receive(:enqueue).with(TrackerProjectValidator::Job.new params)
        TrackerProjectValidator.validate(params)
      end
    end
  end
end
