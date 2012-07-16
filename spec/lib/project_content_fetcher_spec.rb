require 'spec_helper'

describe ProjectContentFetcher do
  let(:project_content_fetcher) { ProjectContentFetcher.new(project) }

  describe "fetch" do
    subject { project_content_fetcher.fetch }

    context "when the feed_url and build_status_url are the same" do
      let(:project) { double :project, feed_url: :feed_url, build_status_url: :feed_url, auth_username: :username, auth_password: :password }
      let(:content) { double :content }

      before do
        UrlRetriever.should_receive(:retrieve_content_at).once.with(:feed_url, :username, :password).and_return(content)
      end

      it { should == { feed_content: content, build_status_content: content } }
    end

    context "when the feed_url and build_status_url are different" do
      let(:project) { double :project, feed_url: :feed_url, build_status_url: :build_status_url, auth_username: :username, auth_password: :password }
      let(:feed_content) { double :content }
      let(:build_status_content) { double :content }

      before do
        UrlRetriever.should_receive(:retrieve_content_at).once.with(:feed_url, :username, :password).and_return(feed_content)
        UrlRetriever.should_receive(:retrieve_content_at).once.with(:build_status_url, :username, :password).and_return(build_status_content)
      end

      it { should == { feed_content: feed_content, build_status_content: build_status_content } }
    end

    context "when retrieving feed_url causes an HTTPError" do
      let(:message) { "error" }

      before do
        UrlRetriever.should_receive(:retrieve_content_at).with(project.feed_url, project.auth_username, project.auth_password).and_raise Net::HTTPError.new(message, 500)
        UrlRetriever.should_receive(:retrieve_content_at).with(project.build_status_url, project.auth_username, project.auth_password)
      end

      context "when the project's current status is the same error" do
        let(:project) { FactoryGirl.create :project }

        before do
          project.statuses.create :error => "HTTP Error retrieving status for project '##{project.id}': error"
        end

        it "should not add an error" do
          expect { subject }.not_to change(ProjectStatus, :count)
        end

        it "should set the feed_content to nil" do
          subject[:feed_content].should be_nil
        end
      end

      context "when the project's current status isn't an error" do
        let(:project) { FactoryGirl.create :project }

        before do
          project.statuses.create success: true
        end

        it "should add an error status" do
          subject
          project.reload.statuses.first.error.should == "HTTP Error retrieving status for project '##{project.id}': #{message}"
        end

        it "should set the feed_content to nil" do
          subject[:feed_content].should be_nil
        end
      end

      context "when the project's current status is a different error" do
        let(:project) { FactoryGirl.create :project }

        before do
          project.statuses.create :error => "some error"
        end

        it "should add an error status" do
          subject
          project.reload.statuses.first.error.should == "HTTP Error retrieving status for project '##{project.id}': #{message}"
        end

        it "should set the feed_content to nil" do
          subject[:feed_content].should be_nil
        end
      end
    end

    context "when retrieving build_status_url causes an HTTPError" do
      let(:project) { FactoryGirl.create :project, building: true }

      before do
        UrlRetriever.should_receive(:retrieve_content_at).with(project.feed_url, project.auth_username, project.auth_password)
        UrlRetriever.should_receive(:retrieve_content_at).with(project.build_status_url, project.auth_username, project.auth_password).and_raise Net::HTTPError.new("error", 500)
      end

      it "should update the project's building status to false" do
        expect { subject }.to change(project, :building).from(true).to(false)
      end

      it "should set the build_status_content to nil" do
        subject[:build_status_content].should be_nil
      end
    end
  end
end
