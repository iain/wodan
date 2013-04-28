class ExampleUseCase

  def initialize(context, value)
    @context = context
    @value = value
  end

  def call
    @value.called
  end

  def result
    1337
  end

end

class OtherExampleUseCase

  def initialize(context, value)
    @context = context
    @value = value
  end

  def call
    @context.use_it(@value)
  end

end

class ExampleDomain < Wodan::Domain

  use_case :use_it, class: "ExampleUseCase"
  use_case :other, class: "OtherExampleUseCase"

end

class DomainWithSuper < Wodan::Domain

  use_case :use_it, class: "ExampleUseCase"

  def use_it(value)
    value.before
    super
    value.after
  end

end
