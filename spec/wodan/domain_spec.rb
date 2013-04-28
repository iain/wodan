require "wodan"
require "support/example_domain"

describe Wodan::Domain do

  it "creates a method for executing a use case" do
    value = double :value
    value.should_receive(:called)
    domain = ExampleDomain.new
    result = domain.use_it(value)
    result.should eq 1337
  end

  it "allows calling use cases in the same domain via the context" do
    value = double :value
    value.should_receive(:called)
    domain = ExampleDomain.new
    domain.other(value)
  end

  it "allows calling super" do
    domain = DomainWithSuper.new
    value = stub :value
    value.should_receive(:before).ordered
    value.should_receive(:called).ordered
    value.should_receive(:after).ordered
    domain.use_it(value)
  end

  it "only creates one module for all use cases" do
    ancestors = ExampleDomain.ancestors.first(3).map(&:to_s)
    ancestors.should eq ["ExampleDomain", "ExampleDomain::UseCases", "Wodan::Domain"]
  end

end
