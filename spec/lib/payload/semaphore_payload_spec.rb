require 'spec_helper'

describe SemaphorePayload do

  let(:status_content) { SemaphoreExample.new(json).read }
  let(:payload) { SemaphorePayload.new.tap{|p| p.status_content = status_content} }
  let(:content) { payload.status_content.first }
  let(:json) { "success.json" }

  let(:status_content_history) { SemaphoreExample.new(json_history).read }
  let(:json_history) { "success_history.json" }

  describe '#convert_content!' do
    subject { payload.convert_content!(status_content) }

    context 'and content is valid' do
      let(:expected_content) { double(:content, key?: false) }
      before do
        JSON.stub(:parse).and_return(expected_content)
      end

      it{ should == [expected_content] }
    end

    context 'when content is corrupt / badly encoded' do
      before do
        JSON.stub(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        payload.processable.should be_false
      end

      context "bad XML data" do
        let(:wrong_status_content) { "some non xml content" }
        it "should log errors" do
          payload.should_receive("log_error")
          payload.status_content = wrong_status_content
        end
      end
    end

    context 'when the project has a branch history url' do
      it "should return the builds array" do
        history_content = payload.convert_content!(status_content_history)
        history_content.count.should == 2
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(content) }

    context 'the payload contains a successful build status' do
      it { should be_true }
    end

    context 'the payload contains a failure build status' do
      let(:json) { "failure.json" }
      it { should be_false }
    end
  end

  describe '#parse_url' do
    subject { payload.parse_url(content) }

    it { should == 'https://semaphoreapp.com/projects/123/branches/456/builds/1' }
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(content) }
    it { should == 1 }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(content) }
    it { should == Time.new(2012, 8, 16, 2, 16, 46, "-07:00") }
  end

end
