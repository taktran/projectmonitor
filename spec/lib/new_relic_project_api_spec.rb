require 'spec_helper'

describe NewRelicProjectApi do
  let(:project) { double(:project, new_relic_api_key: "api_key", new_relic_account_id: "account_id", new_relic_app_id: "app_id") }

  describe "average_response_time" do
    let(:new_relic_api) { NewRelicProjectApi.new(project) }

    before do
      UrlRetriever.stub(retrieve_content_at: response_string)
    end

    describe "A successful request" do
      let(:response_string) do
        ["[", "{\"average_response_time\":0.01},", "{\"average_response_time\":0.02},", "{\"average_response_time\":0.03},",
         "{\"average_response_time\":0.04},", "{\"average_response_time\":0.05},", "{\"average_response_time\":0.06},",
         "{\"average_response_time\":0.07},", "{\"average_response_time\":0.08},", "{\"average_response_time\":0.09},",
         "{\"average_response_time\":0.10},", "{\"average_response_time\":0.11},", "{\"average_response_time\":0.12},",
         "{\"average_response_time\":0.13},", "{\"average_response_time\":0.14},", "{\"average_response_time\":0.15}","]" ].join
      end

      it "returns an array of response times for the last 15 minutes" do
        response_times = new_relic_api.average_response_time
        response_times.should == [
          0.01, 0.02, 0.03, 0.04, 0.05,
          0.06, 0.07, 0.08, 0.09, 0.10,
          0.11, 0.12, 0.13, 0.14, 0.15
        ]
      end
    end

    describe "A erroneous request" do
      describe "malformed JSON" do
        let(:response_string) do
          "this is an invalid string"
        end

        it "returns an empty array" do
          response_times = new_relic_api.average_response_time
          response_times.should == []
        end
      end

      describe "an error message" do
        let(:response_string){ "{\"error\":{\"message\":\"there was an error returned\"}}" }

        it "returns an empty array" do
          response_times = new_relic_api.average_response_time
          response_times.should == []
        end
      end
    end
  end
end
