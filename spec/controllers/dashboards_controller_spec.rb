require 'spec_helper'

describe DashboardsController do

  describe '#index' do
    let(:projects) { double(:projects) }
    let(:aggregate_project) { double(:aggregate_project) }
    let(:aggregate_projects) { double(:aggregate_projects) }

    context 'when an aggregate project id is specified' do
      before do
        AggregateProject.stub(:find).and_return(aggregate_project)
        aggregate_project.stub_chain(:projects, :displayable).and_return(projects)
        projects.stub_chain(:concat, :sort_by).and_return(projects)
      end

      it 'loads the specified project' do
        AggregateProject.should_receive(:find).with('1')
        projects.stub(:take).and_return(projects)
        get :index, aggregate_project_id: 1
      end

      context 'when no tile count is passed in' do
        it 'should limit the tiles by 15' do
          projects.should_receive(:take).with(15)
          get :index, aggregate_project_id: 1
        end
      end

      context 'when a tile count is passed in' do
        it 'should limit the tiles by the passed in amount' do
          projects.should_receive(:take).with(63)
          get :index, tiles_count: 63, aggregate_project_id: 1
        end
      end
    end

    context 'when the aggregate project id is not specified' do
      let(:tags) { 'bleecker' }

      before do
        AggregateProject.stub(:displayable).and_return(aggregate_projects)
        Project.stub_chain(:standalone, :displayable).and_return(projects)
        projects.stub_chain(:concat, :sort_by).and_return(projects)
      end

      it 'gets a collection of aggregate projects by tag' do
        AggregateProject.should_receive(:displayable).with(tags)
        projects.stub(:take).and_return(projects)
        get :index, tags: tags
      end

      context 'when no tile count is passed in' do
        it 'should limit the tiles by 15' do
          projects.should_receive(:take).with(15)
          get :index
        end
      end

      context 'when a tile count is passed in' do
        it 'should limit the tiles by the passed in amount' do
          projects.should_receive(:take).with(63)
          get :index, tiles_count: 63
        end
      end
    end
  end

  context 'when github status is checked' do
    context 'when github is unreachable' do
      let(:error) {Net::HTTPError.new("", nil)}

      before do
        UrlRetriever.should_receive(:retrieve_content_at).and_raise(error)
      end

      it "returns 'bad'" do
        get :github_status, format: :json
        response.body.should == '{"status":"bad"}'
      end
    end

    context 'when github is reachable' do
      before do
        UrlRetriever.should_receive(:retrieve_content_at).and_return('{"status":"minor-outage"}')
      end

      it "returns whatever status github returns" do
        get :github_status, format: :json
        response.body.should == '{"status":"minor-outage"}'
      end
    end
  end
end
