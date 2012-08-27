require 'spec_helper'

describe Project do
  let(:project) { FactoryGirl.build(:jenkins_project) }

  describe "factories" do
    it "should be valid for project" do
      FactoryGirl.build(:project).should be_valid
    end
  end

  describe 'associations' do
    it { should have_many :statuses }
    it { should have_many :payload_log_entries  }
    it { should have_many :dependent_projects }
    it { should belong_to :aggregate_project }
    it { should belong_to :parent_project }
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :type }
  end

  describe "callbacks" do
    before do
      project.statuses << FactoryGirl.build(:project_status)
    end

    context 'when the project is online' do
      let(:project) { FactoryGirl.build(:jenkins_project).tap {|p| p.online = true } }

      it 'should set the last_refreshed_at' do
        project.last_refreshed_at.should be_present
      end
    end

    context 'when the project is offline' do
      let(:project) { FactoryGirl.build(:jenkins_project) }

      it 'should not set the last_refreshed_at' do
        project.last_refreshed_at.should be_nil
      end
    end
  end

  describe 'scopes' do
    describe "standalone" do
      it "should return non aggregated projects" do
        Project.standalone.should include projects(:pivots)
        Project.standalone.should include projects(:socialitis)
        Project.standalone.should_not include projects(:internal_project1)
        Project.standalone.should_not include projects(:internal_project2)
      end
    end

    describe "enabled" do
      let!(:disabled_project) { FactoryGirl.create(:jenkins_project, enabled: false) }

      it "should return only enabled projects" do
        Project.enabled.should include projects(:pivots)
        Project.enabled.should include projects(:socialitis)

        Project.enabled.should_not include disabled_project
      end
    end

    describe "with_statuses" do
      it "returns projects only with statues" do
        projects = Project.with_statuses

        projects.length.should > 9
        projects.should_not include project
        projects.each do |project|
          project.latest_status.should_not be_nil
        end
      end
    end

    describe "with_aggregate_project" do
      subject do
        Project.with_aggregate_project(aggregate_projects(:internal_projects_aggregate)) do
          Project.all
        end
      end

      it { should include projects(:internal_project1) }
      it { should_not include projects(:socialitis) }
    end

    describe '.updateable' do
      subject { Project.updateable }

      let!(:never_updated) { FactoryGirl.create(:jenkins_project, next_poll_at: nil) }
      let!(:updated_recently) { FactoryGirl.create(:jenkins_project, next_poll_at: 5.minutes.ago) }
      let!(:causality_violator) { FactoryGirl.create(:jenkins_project, next_poll_at: 5.minutes.from_now) }

      it { should include never_updated }
      it { should include updated_recently }
      it { should_not include causality_violator }
    end

    describe '.tracker_updateable' do
      subject { Project.tracker_updateable }

      let!(:updateable1) { FactoryGirl.create(:jenkins_project, tracker_auth_token: 'aafaf', tracker_project_id: '1') }
      let!(:updateable2) { FactoryGirl.create(:travis_project, tracker_auth_token: 'aafaf', tracker_project_id: '1') }
      let!(:not_updateable1) { FactoryGirl.create(:jenkins_project, tracker_project_id: '1') }
      let!(:not_updateable2) { FactoryGirl.create(:jenkins_project, tracker_auth_token: 'aafaf') }

      it { should include updateable1 }
      it { should include updateable2 }
      it { should_not include not_updateable1 }
      it { should_not include not_updateable2 }
    end

    describe '.displayable' do
      subject { Project.displayable tags }

      context "when supplying tags" do
        let(:tags) { "southeast, northwest" }

        it "should find tagged with tags" do
          scope = double
          Project.stub(:enabled) { scope }
          scope.should_receive(:find_tagged_with).with(tags)
          subject
        end

        context "when displayable projects are tagged" do
          before do
            projects(:socialitis).update_attributes(tag_list: tags)
            projects(:pivots).update_attributes(tag_list: [])
          end

          it "should return scoped projects" do
            subject.should include projects(:socialitis)
            subject.should_not include projects(:pivots)
          end
        end

      end

      context "when not supplying tags" do
        let(:tags) { nil }

        it "should return scoped projects" do
          subject.should include projects(:pivots)
          subject.should include projects(:socialitis)
        end
      end

    end
  end

  describe '.mark_for_immediate_poll' do
    it 'should set the next_poll_at to nil for all projects' do
      Project.should_receive(:update_all).with(next_poll_at: nil)
      Project.mark_for_immediate_poll
    end
  end

  describe "#code" do
    let(:project) { Project.new(name: "My Cool Project", code: code) }
    subject { project.code }

    context "code set but empty" do
      let(:code) { "" }
      it { should == "myco" }
    end

    context "code not set" do
      let(:code) { nil }
      it { should == "myco" }
    end

    context "code is set" do
      let(:code) { "code" }
      it { should == "code" }
    end
  end

  describe "#last green" do
    it "returns the successful project" do
      project = projects(:socialitis)
      project.statuses = []
      @happy_status = project.statuses.create!(success: true, build_id: 1)
      @sad_status = project.statuses.create!(success: false, build_id: 2)
      project.last_green.should == @happy_status
    end
  end

  describe "#status" do
    let(:project) { projects(:socialitis) }

    it "returns the most recent status" do
      project.status.should == project.recent_statuses.first
    end
  end

  describe "tracker integration" do
    let(:project) { Project.new }

    describe "#tracker_project?" do
      it "should return true if the project has a tracker_project_id and a tracker_auth_token" do
        project.tracker_project_id = double(:tracker_project_id)
        project.tracker_auth_token = double(:tracker_auth_token)
        project.tracker_project?.should be(true)
      end

      it "should return false if the project has a blank tracker_project_id AND a blank tracker_auth_token" do
        project.tracker_project_id = ""
        project.tracker_auth_token = ""
        project.tracker_project?.should be(false)
      end

      it "should return false if the project doesn't have tracker_project_id" do
        project.tracker_project?.should be(false)
      end

      it "should return false if the project doesn't have tracker_auth_token" do
        project.tracker_project?.should be(false)
      end
    end
  end

  describe "#red?, #green? and #yellow?" do
    subject { project }

    context "the project has a failure status" do
      let(:project) { FactoryGirl.create(:jenkins_project, online: true) }
      let!(:status) { ProjectStatus.create!(project: project, success: false, build_id: 1) }

      its(:red?) { should be_true }
      its(:green?) { should be_false }
      its(:yellow?) { should be_false }
    end

    context "the project has a child with a failure status" do
      let(:red_dependent) { Project.new.tap {|p| p.stub(:red?).and_return(true) } }
      let(:project) { Project.new(online: true).tap {|p| p.dependent_projects = [red_dependent]}}

      its(:red?) { should be_true }
      its(:green?) { should be_false }
      its(:yellow?) { should be_false }
    end

    context "the project has a success status" do
      let(:project) { FactoryGirl.create(:project, online: true) }
      let!(:status) { ProjectStatus.create!(project: project, success: true, build_id: 1) }

      its(:red?) { should be_false }
      its(:green?) { should be_true }
      its(:yellow?) { should be_false }
    end

    context "the project has no statuses" do
      let(:project) { Project.new(online: true) }

      its(:red?) { should be_false }
      its(:green?) { should be_false }
      its(:yellow?) { should be_true }
    end

    context "the project is offline" do
      let(:project) { Project.new(online: false) }

      its(:red?) { should be_false }
      its(:green?) { should be_false }
      its(:yellow?) { should be_false }
    end
  end

  describe "#latest_status" do
    let(:project) { FactoryGirl.create :project, name: "my_project" }
    let!(:recent_status_created_a_while_ago) { project.statuses.create(success: true, build_id: 3) }
    let!(:old_status_created_recently) { project.statuses.create(success: true, build_id: 1) }

    it "returns the most recent status" do
      project.latest_status.should == recent_status_created_a_while_ago
    end
  end

  describe "#red_since" do
    it "should return #published_at for the red status after the most recent green status" do
      project = projects(:socialitis)
      red_since = project.red_since

      3.times do |i|
        project.statuses.create!(success: false, build_id: i, :published_at => Time.now + (i+1)*5.minutes)
      end

      project = Project.find(project.id)
      project.red_since.should == red_since
    end

    it "should return nil if the project is currently green" do
      project = projects(:pivots)
      project.should be_green

      project.red_since.should be_nil
    end

    it "should return the published_at of the first recorded status if the project has never been green" do
      project = projects(:never_green)
      project.statuses.detect(&:success?).should be_nil
      project.red_since.should == project.statuses.last.published_at
    end

    it "should return nil if the project has no statuses" do
      project.statuses.should be_empty
      project.red_since.should be_nil
    end

    describe "#breaking build" do
      context "without any green builds" do
        it "should return the first red build" do
          project = projects(:socialitis)
          project.statuses.destroy_all
          first_red = project.statuses.create!(success: false, build_id: 1)
          project.statuses.create!(success: false, build_id: 2)
          project.statuses.create!(success: false, build_id: 3)
          project.breaking_build.should == first_red
        end
      end
    end
  end

  describe "#breaking build" do
    context "without any green builds" do
      it "should return the first red build" do
        project = projects(:socialitis)
        project.red_build_count.should == 1

        project.statuses.create!(success: false, build_id: 100)
        project.red_build_count.should == 2
      end
    end
  end

  describe "#red_build_count" do
    it "should return the number of red builds since the last green build" do
      project = projects(:socialitis)
      project.red_build_count.should == 1

      project.statuses.create(success: false, build_id: 100)
      project.red_build_count.should == 2
    end

    it "should return zero for a green project" do
      project = projects(:pivots)
      project.should be_green

      project.red_build_count.should == 0
    end

    it "should not blow up for a project that has never been green" do
      project = projects(:never_green)
      project.red_build_count.should == project.statuses.count
    end
  end

  describe "#enabled" do
    it "should be enabled by default" do
      project = Project.new
      project.should be_enabled
    end

    it "should store enabledness" do
      projects(:pivots).should be_enabled
      projects(:disabled).should_not be_enabled
    end
  end

  describe "#building?" do
    it "should be true if the project is currently building" do
      projects(:red_currently_building).should be_building
    end

    it "should return false for a project that is not currently building" do
      projects(:many_builds).should_not be_building
    end

    it "should return false for a project that has never been built" do
      projects(:never_built).should_not be_building
    end

    context 'when a child is building' do
      let(:building_dependent) do
        building_dependent = Project.new do |project|
          project.building = true
        end
      end
      let(:project) do
        Project.new do |project|
          project.dependent_projects = [building_dependent]
          project.building = false
        end
      end

      it "should return true if a child is building" do
        project.should be_building
      end
    end
  end

  describe "#set_next_poll" do
    epsilon = 2
    context "with a project poll interval set" do
      before do
        project.polling_interval = 25
      end

      it "should set the next_poll_at to Time.now + the project poll interval" do
        project.set_next_poll
        (project.next_poll_at - (Time.now + project.polling_interval)).abs.should <= epsilon
      end
    end

    context "without a project poll interval set" do
      it "should set the next_poll_at to Time.now + the system default interval" do
        project.set_next_poll
        (project.next_poll_at - (Time.now + Project::DEFAULT_POLLING_INTERVAL)).abs.should <= epsilon
      end
    end
  end

  describe "#has_auth?" do
    it "returns true if either username or password exists" do
      project.auth_username = "uname"
      project.has_auth?.should be_true

      project.auth_username = nil
      project.auth_password = "pwd"
      project.has_auth?.should be_true
    end

    it "returns false if both username and password are blank" do
      project.auth_username = ""
      project.auth_password = nil
      project.has_auth?.should be_false
    end
  end

  describe "#destroy" do
    it "should destroy related statuses" do
      project = projects(:pivots)
      project.statuses.count.should_not == 0
      status_id = project.statuses.first.id
      project.destroy
      proc { ProjectStatus.find(status_id)}.should raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "validation" do
    it "has a valid Factory" do
      FactoryGirl.build(:project).should be_valid
    end
  end

  describe '.project_specific_attributes' do
    subject { project_class.project_specific_attributes }

    context "when a CruiseControlProject" do
      let(:project_class) { CruiseControlProject }

      it { should =~ ['cruise_control_rss_feed_url'] }
    end

    context "when a JenkinsProject" do
      let(:project_class) { JenkinsProject }

      it { should =~ ['jenkins_base_url', 'jenkins_build_name'] }
    end

    context "when a TeamCityProject" do
      let(:project_class) { TeamCityProject }

      it { should =~ ['team_city_base_url', 'team_city_build_id'] }
    end

    context "when a TeamCityRestProject" do
      let(:project_class) { TeamCityRestProject }

      it { should =~ ['team_city_rest_base_url', 'team_city_rest_build_type_id'] }
    end

    context "when a TravisProject" do
      let(:project_class) { TravisProject }

      it { should =~ ['travis_github_account', 'travis_repository'] }
    end
  end

  describe "#has_status?" do
    subject { project.has_status?(status) }

    let(:project) { projects(:socialitis) }

    context "when the project has the status" do
      let!(:status) { project.statuses.create!(build_id: 99) }
      it { should be_true }
    end

    context "when the project does not have the status" do
      let!(:status) { ProjectStatus.create!(build_id: 99) }
      it { should be_false }
    end
  end

  describe '#current_build_url' do
    let(:project) { Project.new }
    subject { project.current_build_url }

    it { should be_nil }
  end

  describe "#generate_guid" do
    let(:project) { FactoryGirl.build(:project) }

    it "calls generate_guid" do
      project.should_receive :generate_guid
      project.save!
    end

    it "generates random GUID" do
      project.save!
      (project.guid).should_not be_nil
      (project.guid).should_not be_empty
    end
  end

  describe '#has_dependent_project?' do
    let(:project) { Project.new }

    it 'should always return false' do
      project.has_dependent_project?(nil).should be_false
    end
  end

end
