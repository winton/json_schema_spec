require 'spec_helper'

describe JsonSchemaSpec do
  describe "#json_schema_params" do

    it "generates proper params" do
      params = json_schema_params(:user, :get)
      expect(params).to eq(
        :request => {
          :id    => params[:request][:id],
          :token => "token"
        },
        :response  => {
          :id      => params[:response][:id],
          :name    => "name",
          :company => {
            :name  => "company:name"
          }
        }
      )
    end
  end
end