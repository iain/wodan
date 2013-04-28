require "spec_helper"
require "wodan/execute_use_case"
require "support/example_use_cases"

describe Wodan::ExecuteUseCase do

  let(:context) { double :context }

  def execute(*args)
    Wodan::ExecuteUseCase.call(*args)
  end

  describe "the simplest use case" do

    it "calls the call method" do
      context.should_receive(:call).with(:other_use_case, 3)
      result = execute(SimpleUseCase, context, :count => 2)
      result.should be_true
    end

  end

  describe "preconditions" do

    it "runs preconditions before executing the use case" do
      context.should_receive(:called)
      execute(UseCaseWithPreconditions, context, true)
    end

    it "doesn't execute the use case when preconditions returns false" do
      context.should_not_receive(:called)
      execute(UseCaseWithPreconditions, context, false)
    end

  end

  describe "postconditions without a result or fallback" do

    it "makes the return value truthy" do
      execute(UseCaseWithPostconditions, context, true).should be_true
    end

    it "raises an exception if the postconditions return false" do
      begin
        execute(UseCaseWithPostconditions, context, false)
      rescue Wodan::PostconditionsFailed => error
        error.message.should eq "Postconditions were not met after executing UseCaseWithPostconditions."
      rescue Object => error
        raise RSpec::Expectations::ExpectationNotMetError, "Wrong exception raised: #{error.class} - #{error.message}"
      else
        raise RSpec::Expectations::ExpectationNotMetError, "No exception raised"
      end
    end

  end

  describe "postconditions with a fallback" do

    it "executes the fallback when postconditions returns false" do
      context.should_receive(:fallback_called)
      execute(UseCaseWithPostconditionsAndFallback, context, false)
    end

    it "doesn't execute fallback when postconditions returns true" do
      context.should_not_receive(:fallback_called)
      execute(UseCaseWithPostconditionsAndFallback, context, true)
    end

  end

  describe "with a result" do

    it "returns the result value" do
      execute(UseCaseWithResult, context, 3).should be 4
    end

  end

  describe "around filter" do

    it "wraps preconditions, postconditions and call" do
      context.should_receive(:before).ordered
      context.should_receive(:preconditions).ordered
      context.should_receive(:called).ordered
      context.should_receive(:postconditions).ordered
      context.should_receive(:after).ordered
      context.should_receive(:result).ordered
      execute(UseCaseWithAround, context)
    end

  end

  describe "with a rescue" do

    it "returns the result value" do
      context.should_receive(:rescued).with(instance_of(UseCaseWithRescue::SpecialError))
      expect { execute(UseCaseWithRescue, context) }.not_to raise_error
    end

  end

end
