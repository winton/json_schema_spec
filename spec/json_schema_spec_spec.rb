require 'spec_helper'

describe JsonSchemaSpec do
  describe "#json_schema_params" do

    it "generates proper params" do
      request, response = json_schema_params(:user, :get, :required => :bio)

      expect(request).to eq(
        :id    => request[:id],
        :token => "token"
      )
      
      expect(response).to eq([{
        :id       => response[0][:id],
        :admin    => 0,
        :bio      => "bio",
        :name     => "name",
        :company  => {
          :name   => "company:name"
        },
        :articles => [
          {
            :body  => "articles:body",
            :title => "articles:title"
          }
        ]
      }])
    end
  end
end