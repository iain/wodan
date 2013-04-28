module Wodan

  PostconditionsFailed = Class.new(StandardError)

  class ExecuteUseCase

    attr_reader :use_case, :initialized_case

    def self.call(*args)
      new(*args).call
    end

    def initialize(use_case, context, *args)
      @use_case = use_case
      @initialized_case = use_case.new(context, *args)
    end

    def call
      should_call_result = false
      around do
        if preconditions_passed?
          initialized_case.call
          if postconditions_passed?
            should_call_result = true
          else
            execute_fallback
          end
        end
      end
      if should_call_result
        successful_result
      else
        false
      end
    rescue Object => error
      if initialized_case.respond_to?(:on_error)
        initialized_case.on_error(error)
      else
        raise
      end
    end

    private

    def around
      if initialized_case.respond_to?(:around)
        initialized_case.around { yield }
      else
        yield
      end
    end

    def preconditions_passed?
      if initialized_case.respond_to?(:preconditions)
        initialized_case.preconditions
      else
        true
      end
    end

    def postconditions_passed?
      if initialized_case.respond_to?(:postconditions)
        initialized_case.postconditions
      else
        true
      end
    end

    def execute_fallback
      if initialized_case.respond_to?(:fallback)
        initialized_case.fallback
      else
        fail_on_postconditions!
      end
    end

    def fail_on_postconditions!
      raise PostconditionsFailed, "Postconditions were not met after executing #{use_case}."
    end

    def successful_result
      if initialized_case.respond_to?(:result)
        initialized_case.result
      else
        true
      end
    end

  end
end
