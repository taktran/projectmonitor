require 'spec_helper'

describe NewRelicProjectApi do
  context "with the real service", :vcr do
    subject { NewRelicProjectApi.new(project) }

    before do
      subject.stub(end_time: Time.new(2012,11,15,2,20,45).to_datetime.to_s)
      subject.stub(begin_time: Time.new(2012,11,15,2,5,45).to_datetime.to_s)
    end

    let(:project) { FactoryGirl.create :project, new_relic_api_key: "4b7dd24681d52b565c3c5001d31ff0167e840f50dcb4fa6", new_relic_account_id: 214658, new_relic_app_id: 1395343}

    context "average_response_time" do
      it "should return 15 results" do
        subject.average_response_time.should == 15.times.map { 0 }
      end
    end
  end
end
