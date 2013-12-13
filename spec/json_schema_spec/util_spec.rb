require 'spec_helper'

describe JsonSchemaSpec::Util do
  describe "#deep_merge" do

    it "handles arrays appropriately" do
      result = JsonSchemaSpec::Util.deep_merge(
        { :a => [ { :b => 1, :d => 3 } ], :a2 => true },
        { :a => [ { :c => 2, :e => 4 } ] }
      )
      expect(result).to eq(:a => [ { :b => 1, :c => 2, :d => 3, :e => 4 } ], :a2 => true)
    end
  end
end