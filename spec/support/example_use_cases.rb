class SimpleUseCase

  def initialize(context, options = {})
    @context = context
    @count = options.fetch(:count)
  end

  def call
    @context.call(:other_use_case, @count + 1)
  end

end

class UseCaseWithPreconditions

  def initialize(context, success)
    @context = context
    @success = success
  end

  def preconditions
    @success
  end

  def call
    @context.called
  end

end

class UseCaseWithPostconditions

  def initialize(context, success)
    @context = context
    @success = success
  end

  def call
  end

  def postconditions
    @success
  end

end

class UseCaseWithPostconditionsAndFallback

  def initialize(context, success)
    @context = context
    @success = success
  end

  def call
  end

  def postconditions
    @success
  end

  def fallback
    @context.fallback_called
  end

end


class UseCaseWithResult

  def initialize(context, count)
    @context = context
    @count = count
  end

  def call
    @count += 1
  end

  def result
    @count
  end

end

class UseCaseWithAround

  def initialize(context)
    @context = context
  end

  def call
    @context.called
  end

  def result
    @context.result
  end

  def preconditions
    @context.preconditions
    true
  end

  def postconditions
    @context.postconditions
    true
  end

  def around
    @context.before
    yield
    @context.after
  end

end

class UseCaseWithRescue

  SpecialError = Class.new(Exception)

  def initialize(context)
    @context = context
  end

  def call
    raise SpecialError
  end

  def on_error(error)
    @context.rescued(error)
  end

end
