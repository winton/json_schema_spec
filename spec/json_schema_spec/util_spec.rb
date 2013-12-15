require 'spec_helper'

describe JsonSchemaSpec::Util do
  describe "#deep_merge" do

    let(:input) do
      [
        { :a => [ { :b => 1, :d => 3 } ], :a2 => true },
        { :a => [ { :c => 2, :e => 4 } ] }
      ]
    end

    let(:output) do
      {
        :a  => [ { :b => 1, :c => 2, :d => 3, :e => 4 } ],
        :a2 => true
      }
    end

    it "handles hashes with arrays" do
      result = JsonSchemaSpec::Util.deep_merge(input[0], input[1])
      expect(result).to eq(output)
    end

    it "handles arrays with hashes" do
      result = JsonSchemaSpec::Util.deep_merge(
        [ input[0] ], [ input[1] ]
      )
      expect(result).to eq([ output ])
    end
  end
end