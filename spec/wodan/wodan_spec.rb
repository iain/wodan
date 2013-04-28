require 'spec_helper'
require 'wodan'

describe Wodan do

  it "can execute an arbitray use case" do
    argument1, argument2 = stub, stub
    Wodan::ExecuteUseCase.should_receive(:call).with(argument1, argument2)
    Wodan.call(argument1, argument2)
  end

end
